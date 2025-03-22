import os
import logging
import telebot
import pyodbc
import pandas as pd
import tempfile
import time
import sys
import requests
from datetime import datetime
from telebot import types
from telebot.apihelper import ApiTelegramException

# تنظیمات لاگینگ
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO,
    handlers=[
        logging.FileHandler("bot_log.txt", encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# تنظیمات اتصال به دیتابیس
DB_SERVER = '.\\SQL2014'  # از دو بک‌اسلش استفاده کنید
DB_NAME = 'Bot_Report'
DB_USERNAME = 'Ebtekar'
DB_PASSWORD = 'Ebtekar@sql'

# توکن ربات تلگرام
TOKEN = '7993408751:AAGRaRxgc9TiDJ3u5P9hFp8WYf6BJpCqiKs'

# تنظیمات مربوط به تلاش مجدد
MAX_RETRIES = 10
RETRY_DELAY = 5  # ثانیه

# ایجاد نمونه ربات با تنظیمات مقاوم‌سازی
bot = telebot.TeleBot(TOKEN)

# دیکشنری برای ذخیره وضعیت کاربران
user_states = {}
user_data = {}

# وضعیت‌های مختلف کاربر
class States:
    IDLE = 0
    WAITING_FOR_CATEGORY = 1
    WAITING_FOR_REPORT = 2
    WAITING_FOR_PARAMETERS = 3

# اتصال به دیتابیس با مکانیزم تلاش مجدد
def get_db_connection():
    retries = 0
    while retries < MAX_RETRIES:
        try:
            conn_str = f'DRIVER={{SQL Server}};SERVER={DB_SERVER};DATABASE={DB_NAME};UID={DB_USERNAME};PWD={DB_PASSWORD}'
            return pyodbc.connect(conn_str)
        except pyodbc.Error as e:
            retries += 1
            logger.error(f"خطا در اتصال به دیتابیس (تلاش {retries}/{MAX_RETRIES}): {e}")
            if retries < MAX_RETRIES:
                time.sleep(RETRY_DELAY)
            else:
                raise Exception(f"پس از {MAX_RETRIES} تلاش، اتصال به دیتابیس ناموفق بود: {e}")

# تابع ارسال پیام با مکانیزم تلاش مجدد
def send_message_with_retry(chat_id, text, reply_markup=None, parse_mode=None):
    retries = 0
    while retries < MAX_RETRIES:
        try:
            return bot.send_message(chat_id, text, reply_markup=reply_markup, parse_mode=parse_mode)
        except ApiTelegramException as e:
            retries += 1
            logger.error(f"خطا در ارسال پیام (تلاش {retries}/{MAX_RETRIES}): {e}")
            if retries < MAX_RETRIES:
                time.sleep(RETRY_DELAY)
            else:
                logger.error(f"پس از {MAX_RETRIES} تلاش، ارسال پیام ناموفق بود: {e}")
                return None

# تابع ارسال فایل با مکانیزم تلاش مجدد
def send_document_with_retry(chat_id, document, caption=None, visible_file_name=None):
    retries = 0
    while retries < MAX_RETRIES:
        try:
            return bot.send_document(chat_id, document, caption=caption, visible_file_name=visible_file_name)
        except ApiTelegramException as e:
            retries += 1
            logger.error(f"خطا در ارسال فایل (تلاش {retries}/{MAX_RETRIES}): {e}")
            if retries < MAX_RETRIES:
                time.sleep(RETRY_DELAY)
            else:
                logger.error(f"پس از {MAX_RETRIES} تلاش، ارسال فایل ناموفق بود: {e}")
                return None

# تابع ویرایش پیام با مکانیزم تلاش مجدد
def edit_message_text_with_retry(text, chat_id, message_id, reply_markup=None):
    retries = 0
    while retries < MAX_RETRIES:
        try:
            return bot.edit_message_text(text, chat_id, message_id, reply_markup=reply_markup)
        except ApiTelegramException as e:
            retries += 1
            logger.error(f"خطا در ویرایش پیام (تلاش {retries}/{MAX_RETRIES}): {e}")
            if retries < MAX_RETRIES:
                time.sleep(RETRY_DELAY)
            else:
                logger.error(f"پس از {MAX_RETRIES} تلاش، ویرایش پیام ناموفق بود: {e}")
                return None

# تابع پاسخ به پیام با مکانیزم تلاش مجدد
def reply_to_with_retry(message, text, reply_markup=None):
    retries = 0
    while retries < MAX_RETRIES:
        try:
            return bot.reply_to(message, text, reply_markup=reply_markup)
        except ApiTelegramException as e:
            retries += 1
            logger.error(f"خطا در پاسخ به پیام (تلاش {retries}/{MAX_RETRIES}): {e}")
            if retries < MAX_RETRIES:
                time.sleep(RETRY_DELAY)
            else:
                logger.error(f"پس از {MAX_RETRIES} تلاش، پاسخ به پیام ناموفق بود: {e}")
                return None

# تابع پاسخ به callback query با مکانیزم تلاش مجدد
def answer_callback_query_with_retry(callback_query_id, text=None):
    retries = 0
    while retries < MAX_RETRIES:
        try:
            return bot.answer_callback_query(callback_query_id, text=text)
        except ApiTelegramException as e:
            retries += 1
            logger.error(f"خطا در پاسخ به callback query (تلاش {retries}/{MAX_RETRIES}): {e}")
            if retries < MAX_RETRIES:
                time.sleep(RETRY_DELAY)
            else:
                logger.error(f"پس از {MAX_RETRIES} تلاش، پاسخ به callback query ناموفق بود: {e}")
                return None

# دستور شروع
@bot.message_handler(commands=['start'])
def start_command(message):
    telegram_id = str(message.from_user.id)
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # بررسی وجود کاربر در دیتابیس
        cursor.execute("SELECT UserID, FullName, Role FROM Users WHERE TelegramID = ?", (telegram_id,))
        user = cursor.fetchone()
        
        if not user:
            reply_to_with_retry(message, "شما در سیستم ثبت نشده‌اید. لطفاً با مدیر سیستم تماس بگیرید.")
            return
        
        # ذخیره اطلاعات کاربر
        user_data[telegram_id] = {
            'user_id': user[0],
            'full_name': user[1],
            'role': user[2],
            'current_report': None,
            'parameters': {}
        }
        
        # دریافت دسته‌بندی‌های گزارش‌های قابل دسترس برای کاربر
        cursor.execute("""
            SELECT DISTINCT rc.CategoryName,rc.[DisplayOrder]
            FROM Reports r
            JOIN UserReportsAccess ura ON r.ReportID = ura.ReportID
            JOIN ReportCategories rc ON r.CategoryID = rc.CategoryID                       
            WHERE ura.UserID = ?
            ORDER BY rc.[DisplayOrder]
        """, (user[0],))
        
        categories = [row[0] for row in cursor.fetchall()]
        
        if not categories:
            reply_to_with_retry(message, "شما به هیچ گزارشی دسترسی ندارید. لطفاً با مدیر سیستم تماس بگیرید.")
            return
        
        # ایجاد کیبورد برای انتخاب دسته‌بندی
        markup = types.InlineKeyboardMarkup(row_width=2)
        buttons = [types.InlineKeyboardButton(category, callback_data=f"cat_{category}") for category in categories]
        markup.add(*buttons)
        
        send_message_with_retry(
            message.chat.id,
            f"خوش آمدید {user[1]}!\n"
            "لطفاً دسته‌بندی گزارش مورد نظر خود را انتخاب کنید:",
            reply_markup=markup
        )
        
        # تنظیم وضعیت کاربر
        user_states[telegram_id] = States.WAITING_FOR_CATEGORY
        
    except Exception as e:
        logger.error(f"خطا در شروع ربات: {e}")
        reply_to_with_retry(message, "خطایی رخ داده است. لطفاً دوباره تلاش کنید.")
    finally:
        if 'conn' in locals():
            conn.close()

# پردازش انتخاب دسته‌بندی
@bot.callback_query_handler(func=lambda call: call.data.startswith('cat_'))
def process_category_selection(call):
    telegram_id = str(call.from_user.id)
    
    if telegram_id not in user_data:
        answer_callback_query_with_retry(call.id, "لطفاً ابتدا دستور /start را وارد کنید.")
        return
    
    category = call.data.replace("cat_", "")
    user_data[telegram_id]['current_category'] = category
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # دریافت گزارش‌های قابل دسترس در دسته انتخاب شده
        cursor.execute("""
            SELECT r.ReportID, r.ReportName
            FROM Reports r
            JOIN UserReportsAccess ura ON r.ReportID = ura.ReportID                  
            JOIN ReportCategories rc ON r.CategoryID = rc.CategoryID
            WHERE ura.UserID = ? AND rc.Categoryname = ?
            ORDER BY r.ReportName
        """, (user_data[telegram_id]['user_id'], category))
        
        reports = cursor.fetchall()
        
        # ایجاد کیبورد برای انتخاب گزارش
        markup = types.InlineKeyboardMarkup(row_width=1)
        for report in reports:
            markup.add(types.InlineKeyboardButton(report[1], callback_data=f"rep_{report[0]}"))
        
        # اضافه کردن دکمه بازگشت
        markup.add(types.InlineKeyboardButton("🔙 بازگشت به دسته‌بندی‌ها", callback_data="back_to_categories"))
        
        edit_message_text_with_retry(
            f"لطفاً گزارش مورد نظر خود را از دسته «{category}» انتخاب کنید:",
            call.message.chat.id,
            call.message.message_id,
            reply_markup=markup
        )
        
        # تنظیم وضعیت کاربر
        user_states[telegram_id] = States.WAITING_FOR_REPORT
        
    except Exception as e:
        logger.error(f"خطا در انتخاب دسته‌بندی: {e}")
        answer_callback_query_with_retry(call.id, "خطایی رخ داده است. لطفاً دوباره تلاش کنید.")
    finally:
        if 'conn' in locals():
            conn.close()

# بازگشت به منوی دسته‌بندی‌ها
@bot.callback_query_handler(func=lambda call: call.data == "back_to_categories")
def back_to_categories(call):
    telegram_id = str(call.from_user.id)
    
    if telegram_id not in user_data:
        answer_callback_query_with_retry(call.id, "لطفاً ابتدا دستور /start را وارد کنید.")
        return
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # دریافت دسته‌بندی‌های گزارش‌های قابل دسترس برای کاربر
        cursor.execute("""
            SELECT DISTINCT rc.CategoryName,rc.[DisplayOrder]
            FROM Reports r
            JOIN UserReportsAccess ura ON r.ReportID = ura.ReportID
            JOIN ReportCategories rc ON r.CategoryID = rc.CategoryID                       
            WHERE ura.UserID = ?
            ORDER BY rc.[DisplayOrder]
        """, (user_data[telegram_id]['user_id'],))
        
        categories = [row[0] for row in cursor.fetchall()]
        
        # ایجاد کیبورد برای انتخاب دسته‌بندی
        markup = types.InlineKeyboardMarkup(row_width=2)
        buttons = [types.InlineKeyboardButton(category, callback_data=f"cat_{category}") for category in categories]
        markup.add(*buttons)
        
        edit_message_text_with_retry(
            "لطفاً دسته‌بندی گزارش مورد نظر خود را انتخاب کنید:",
            call.message.chat.id,
            call.message.message_id,
            reply_markup=markup
        )
        
        # تنظیم وضعیت کاربر
        user_states[telegram_id] = States.WAITING_FOR_CATEGORY
        
    except Exception as e:
        logger.error(f"خطا در بازگشت به دسته‌بندی‌ها: {e}")
        answer_callback_query_with_retry(call.id, "خطایی رخ داده است. لطفاً دوباره تلاش کنید.")
    finally:
        if 'conn' in locals():
            conn.close()

# پردازش انتخاب گزارش
@bot.callback_query_handler(func=lambda call: call.data.startswith('rep_'))
def process_report_selection(call):
    telegram_id = str(call.from_user.id)
    
    if telegram_id not in user_data:
        answer_callback_query_with_retry(call.id, "لطفاً ابتدا دستور /start را وارد کنید.")
        return
    
    report_id = int(call.data.replace("rep_", ""))
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # دریافت اطلاعات گزارش انتخاب شده
        cursor.execute("""
            SELECT ReportName, ProcedureName, Parameters
            FROM Reports
            WHERE ReportID = ?
        """, (report_id,))
        
        report = cursor.fetchone()
        
        if not report:
            answer_callback_query_with_retry(call.id, "گزارش مورد نظر یافت نشد.")
            return
        
        # ذخیره اطلاعات گزارش
        user_data[telegram_id]['current_report'] = {
            'id': report_id,
            'name': report[0],
            'procedure': report[1],
            'parameters': report[2]
        }
        
        # بررسی وجود پارامتر
        if report[2]:
            # پارامترها را به لیست تبدیل می‌کنیم
            params = report[2].split(',')
            user_data[telegram_id]['parameters'] = {param: None for param in params}
            
            # درخواست اولین پارامتر
            first_param = params[0]
            
            markup = types.InlineKeyboardMarkup()
            markup.add(types.InlineKeyboardButton("🔙 بازگشت به لیست گزارش‌ها", callback_data=f"back_to_reports_{user_data[telegram_id]['current_category']}"))
            
            edit_message_text_with_retry(
                f"گزارش «{report[0]}» انتخاب شد.\n\n"
                f"لطفاً مقدار پارامتر «{first_param}» را وارد کنید:",
                call.message.chat.id,
                call.message.message_id,
                reply_markup=markup
            )
            
            # تنظیم وضعیت کاربر
            user_states[telegram_id] = States.WAITING_FOR_PARAMETERS
            user_data[telegram_id]['current_parameter'] = first_param
            
        else:
            # گزارش بدون پارامتر است، مستقیماً اجرا می‌کنیم
            answer_callback_query_with_retry(call.id, "در حال تهیه گزارش...")
            edit_message_text_with_retry(
                f"گزارش «{report[0]}» در حال آماده‌سازی است. لطفاً منتظر بمانید...",
                call.message.chat.id,
                call.message.message_id
            )
            
            # اجرای گزارش و ارسال نتیجه
            generate_and_send_report(call.message.chat.id, telegram_id)
            
    except Exception as e:
        logger.error(f"خطا در انتخاب گزارش: {e}")
        answer_callback_query_with_retry(call.id, "خطایی رخ داده است. لطفاً دوباره تلاش کنید.")
    finally:
        if 'conn' in locals():
            conn.close()

# بازگشت به لیست گزارش‌ها
@bot.callback_query_handler(func=lambda call: call.data.startswith('back_to_reports_'))
def back_to_reports(call):
    telegram_id = str(call.from_user.id)
    
    if telegram_id not in user_data:
        answer_callback_query_with_retry(call.id, "لطفاً ابتدا دستور /start را وارد کنید.")
        return
    
    category = call.data.replace("back_to_reports_", "")
    user_data[telegram_id]['current_category'] = category
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # دریافت گزارش‌های قابل دسترس در دسته انتخاب شده
        cursor.execute("""
            SELECT r.ReportID, r.ReportName
            FROM Reports r
            JOIN UserReportsAccess ura ON r.ReportID = ura.ReportID
            WHERE ura.UserID = ? AND r.Category = ?
            ORDER BY r.ReportName
        """, (user_data[telegram_id]['user_id'], category))
        
        reports = cursor.fetchall()
        
        # ایجاد کیبورد برای انتخاب گزارش
        markup = types.InlineKeyboardMarkup(row_width=1)
        for report in reports:
            markup.add(types.InlineKeyboardButton(report[1], callback_data=f"rep_{report[0]}"))
        
        # اضافه کردن دکمه بازگشت
        markup.add(types.InlineKeyboardButton("🔙 بازگشت به دسته‌بندی‌ها", callback_data="back_to_categories"))
        
        edit_message_text_with_retry(
            f"لطفاً گزارش مورد نظر خود را از دسته «{category}» انتخاب کنید:",
            call.message.chat.id,
            call.message.message_id,
            reply_markup=markup
        )
        
        # تنظیم وضعیت کاربر
        user_states[telegram_id] = States.WAITING_FOR_REPORT
        
    except Exception as e:
        logger.error(f"خطا در بازگشت به لیست گزارش‌ها: {e}")
        answer_callback_query_with_retry(call.id, "خطایی رخ داده است. لطفاً دوباره تلاش کنید.")
    finally:
        if 'conn' in locals():
            conn.close()

# دریافت پارامترهای گزارش
@bot.message_handler(func=lambda message: str(message.from_user.id) in user_states and user_states[str(message.from_user.id)] == States.WAITING_FOR_PARAMETERS)
def process_parameter_input(message):
    telegram_id = str(message.from_user.id)
    
    if telegram_id not in user_data or 'current_parameter' not in user_data[telegram_id]:
        reply_to_with_retry(message, "لطفاً ابتدا یک گزارش انتخاب کنید.")
        return
    
    current_param = user_data[telegram_id]['current_parameter']
    param_value = message.text.strip()
    
    # ذخیره مقدار پارامتر
    user_data[telegram_id]['parameters'][current_param] = param_value
    
    # بررسی آیا پارامتر دیگری باقی مانده است
    params = list(user_data[telegram_id]['parameters'].keys())
    current_index = params.index(current_param)
    
    if current_index < len(params) - 1:
        # هنوز پارامترهای دیگری باقی مانده‌اند
        next_param = params[current_index + 1]
        user_data[telegram_id]['current_parameter'] = next_param
        
        markup = types.InlineKeyboardMarkup()
        markup.add(types.InlineKeyboardButton("🔙 بازگشت به لیست گزارش‌ها", callback_data=f"back_to_reports_{user_data[telegram_id]['current_category']}"))
        
        send_message_with_retry(
            message.chat.id,
            f"لطفاً مقدار پارامتر «{next_param}» را وارد کنید:",
            reply_markup=markup
        )
    else:
        # همه پارامترها دریافت شده‌اند، اجرای گزارش
        send_message_with_retry(
            message.chat.id,
            f"گزارش «{user_data[telegram_id]['current_report']['name']}» در حال آماده‌سازی است. لطفاً منتظر بمانید..."
        )
        
        # اجرای گزارش و ارسال نتیجه
        generate_and_send_report(message.chat.id, telegram_id)

# تابع تولید و ارسال گزارش
# ابتدا باید کتابخانه‌های مورد نیاز را نصب کنید:
# pip install pywin32

import os
import tempfile
from datetime import datetime
import win32com.client
import pythoncom

# تابع تولید و ارسال گزارش
def generate_and_send_report(chat_id, telegram_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        report_info = user_data[telegram_id]['current_report']
        procedure_name = report_info['procedure']
        report_id = report_info['id']
        report_name = report_info['name']
        
        # بررسی آیا این یک داشبورد است (procedure خالی یا __)
        is_dashboard = not procedure_name or procedure_name.strip() == '' or procedure_name == '__'
        
        if is_dashboard:
            # این یک داشبورد است - باید از منطق اختصاصی استفاده کنیم
            send_message_with_retry(chat_id, f"در حال آماده‌سازی داشبورد «{report_name}»... لطفاً منتظر بمانید.")
            
            # بررسی نوع خروجی (PDF یا Excel)
            is_pdf = "pdf" in report_name.lower()
            
            # ارسال داشبورد از فایل آماده
            send_prepared_dashboard(chat_id, telegram_id, report_name, is_pdf)
            
            # ثبت لاگ درخواست گزارش
            cursor.execute("""
                INSERT INTO ReportLogs (UserID, ReportID, RequestDate, Parameters)
                VALUES (?, ?, GETDATE(), ?)
            """, (
                user_data[telegram_id]['user_id'],
                report_id,
                str(user_data[telegram_id]['parameters']) if 'parameters' in user_data[telegram_id] else None
            ))
            conn.commit()
            
            return
        
        # ادامه روند معمولی برای گزارش‌های استاندارد
        # ساخت پارامترهای پروسیجر
        params = []
        param_values = []
        
        if 'parameters' in user_data[telegram_id] and user_data[telegram_id]['parameters']:
            for param_name, param_value in user_data[telegram_id]['parameters'].items():
                params.append(f"@{param_name}=?")
                param_values.append(param_value)
        
        # ساخت و اجرای کوئری
        if params:
            query = f"EXEC {procedure_name} {', '.join(params)}"
            cursor.execute(query, param_values)
        else:
            query = f"EXEC {procedure_name}"
            cursor.execute(query)
        
        # دریافت نتایج
        columns = [column[0] for column in cursor.description]
        results = cursor.fetchall()
        
        if not results:
            send_message_with_retry(chat_id, "گزارش هیچ داده‌ای برای نمایش ندارد.")
            return
        
        # تبدیل نتایج به دیتافریم پانداس
        df = pd.DataFrame.from_records(results, columns=columns)
        
        # ثبت لاگ درخواست گزارش
        cursor.execute("""
            INSERT INTO ReportLogs (UserID, ReportID, RequestDate, Parameters)
            VALUES (?, ?, GETDATE(), ?)
        """, (
            user_data[telegram_id]['user_id'],
            report_info['id'],
            str(user_data[telegram_id]['parameters']) if 'parameters' in user_data[telegram_id] else None
        ))
        conn.commit()
        
        # ایجاد فایل اکسل
        with tempfile.NamedTemporaryFile(suffix='.xlsx', delete=False) as temp_file:
            excel_path = temp_file.name
        
        # تنظیم فرمت‌بندی اکسل
        with pd.ExcelWriter(excel_path, engine='xlsxwriter') as writer:
            df.to_excel(writer, sheet_name='Report', index=False)
            
            workbook = writer.book
            worksheet = writer.sheets['Report']
            
            # فرمت‌بندی هدر
            header_format = workbook.add_format({
                'bold': True,
                'text_wrap': True,
                'valign': 'top',
                'fg_color': '#D7E4BC',
                'border': 1
            })
            
            # اعمال فرمت به هدر
            for col_num, value in enumerate(df.columns.values):
                worksheet.write(0, col_num, value, header_format)
                
            # تنظیم عرض ستون‌ها
            for i, col in enumerate(df.columns):
                column_width = max(df[col].astype(str).map(len).max(), len(col)) + 2
                worksheet.set_column(i, i, column_width)
        
        # ارسال فایل اکسل با مکانیزم تلاش مجدد
        retries = 0
        while retries < MAX_RETRIES:
            try:
                with open(excel_path, 'rb') as file:
                    current_time = datetime.now().strftime("%Y%m%d_%H%M%S")
                    file_name = f"{report_info['name']}_{current_time}.xlsx"
                    send_document_with_retry(
                        chat_id,
                        file,
                        caption=f"گزارش «{report_info['name']}»\nتاریخ: {datetime.now().strftime('%Y/%m/%d %H:%M:%S')}",
                        visible_file_name=file_name
                    )
                break
            except Exception as e:
                retries += 1
                logger.error(f"خطا در ارسال فایل اکسل (تلاش {retries}/{MAX_RETRIES}): {e}")
                if retries < MAX_RETRIES:
                    time.sleep(RETRY_DELAY)
                else:
                    send_message_with_retry(chat_id, "خطا در ارسال فایل گزارش. لطفاً دوباره تلاش کنید.")
        
        # پاکسازی فایل موقت
        try:
            os.unlink(excel_path)
        except Exception as e:
            logger.error(f"خطا در حذف فایل موقت: {e}")
        
        # بازگشت به منوی دسته‌بندی‌ها
        markup = types.InlineKeyboardMarkup(row_width=2)
        markup.add(types.InlineKeyboardButton("🔙 بازگشت به منوی اصلی", callback_data="back_to_categories"))
        
        send_message_with_retry(
            chat_id,
            "گزارش با موفقیت ارسال شد. آیا می‌خواهید گزارش دیگری دریافت کنید؟",
            reply_markup=markup
        )
        
        # پاکسازی پارامترها
        if 'parameters' in user_data[telegram_id]:
            user_data[telegram_id]['parameters'] = {}
        
        # تنظیم وضعیت کاربر
        user_states[telegram_id] = States.IDLE
        
    except pyodbc.Error as e:
        logger.error(f"خطا در تولید گزارش: {e}")
        
        # بررسی نوع خطا و ارائه پیام مناسب
        error_message = str(e)
        user_friendly_message = "خطا در تولید گزارش: "
        
        if "Error converting data type nvarchar to date" in error_message:
            # خطای تبدیل تاریخ
            param_name = None
            if 'current_parameter' in user_data[telegram_id]:
                param_name = user_data[telegram_id]['current_parameter']
            
            if param_name:
                user_friendly_message = f"فرمت تاریخ وارد شده برای پارامتر «{param_name}» صحیح نیست.\n\nلطفاً تاریخ را به فرمت صحیح (مثال: 1402/01/01) وارد کنید."
            else:
                user_friendly_message = "فرمت تاریخ وارد شده صحیح نیست.\n\nلطفاً تاریخ را به فرمت صحیح (مثال: 1402/01/01) وارد کنید."
        
        elif "Error converting data type nvarchar to numeric" in error_message:
            # خطای تبدیل عدد
            param_name = None
            if 'current_parameter' in user_data[telegram_id]:
                param_name = user_data[telegram_id]['current_parameter']
            
            if param_name:
                user_friendly_message = f"مقدار وارد شده برای پارامتر «{param_name}» باید عدد باشد.\n\nلطفاً یک عدد معتبر وارد کنید."
            else:
                user_friendly_message = "مقدار وارد شده باید عدد باشد.\n\nلطفاً یک عدد معتبر وارد کنید."
        
        elif "String or binary data would be truncated" in error_message:
            # خطای طول رشته
            user_friendly_message = "مقدار وارد شده بیش از حد مجاز است.\n\nلطفاً متن کوتاه‌تری وارد کنید."
        
        elif "Violation of PRIMARY KEY constraint" in error_message:
            # خطای کلید اصلی
            user_friendly_message = "این رکورد قبلاً در سیستم ثبت شده است."
        
        elif "The multi-part identifier" in error_message:
            # خطای شناسایی فیلد
            user_friendly_message = "خطای داخلی در پایگاه داده رخ داده است.\n\nلطفاً با پشتیبانی تماس بگیرید."
        
        elif "Invalid object name" in error_message:
            # خطای نام جدول
            user_friendly_message = "خطای داخلی در پایگاه داده رخ داده است.\n\nلطفاً با پشتیبانی تماس بگیرید."
        
        else:
            # سایر خطاها
            user_friendly_message = f"خطا در اجرای گزارش: {str(e)}\n\nلطفاً مقادیر پارامترها را بررسی کنید یا با پشتیبانی تماس بگیرید."
        
        # ارسال پیام خطا به کاربر
        markup = types.InlineKeyboardMarkup()
        markup.add(types.InlineKeyboardButton("🔄 تلاش مجدد", callback_data=f"rep_{user_data[telegram_id]['current_report']['id']}"))
        markup.add(types.InlineKeyboardButton("🔙 بازگشت به لیست گزارش‌ها", callback_data=f"back_to_reports_{user_data[telegram_id]['current_category']}"))
        
        send_message_with_retry(chat_id, user_friendly_message, reply_markup=markup)
        
    except Exception as e:
        logger.error(f"خطا در تولید گزارش: {e}")
        
        # ارسال پیام خطای عمومی
        markup = types.InlineKeyboardMarkup()
        markup.add(types.InlineKeyboardButton("🔄 تلاش مجدد", callback_data=f"rep_{user_data[telegram_id]['current_report']['id']}"))
        markup.add(types.InlineKeyboardButton("🔙 بازگشت به لیست گزارش‌ها", callback_data=f"back_to_reports_{user_data[telegram_id]['current_category']}"))
        
        send_message_with_retry(
            chat_id, 
            f"خطا در اجرای گزارش: {str(e)}\n\nلطفاً مقادیر پارامترها را بررسی کنید یا با پشتیبانی تماس بگیرید.",
            reply_markup=markup
        )
    finally:
        if 'conn' in locals():
            conn.close()

# تابع ارسال داشبورد از فایل آماده
def send_prepared_dashboard(chat_id, telegram_id, report_name, is_pdf=False):
    try:
        # مسیر فایل اکسل داشبورد
        dashboard_excel_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "dashboard", "dashboard.xlsx")
        
        # بررسی وجود فایل
        if not os.path.exists(dashboard_excel_path):
            send_message_with_retry(chat_id, "فایل داشبورد یافت نشد. لطفاً با پشتیبانی تماس بگیرید.")
            logger.error(f"فایل داشبورد در مسیر {dashboard_excel_path} یافت نشد.")
            return
        
        current_time = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # اگر خروجی PDF درخواست شده باشد
        if is_pdf:
            # ایجاد فایل PDF موقت
            with tempfile.NamedTemporaryFile(suffix='.pdf', delete=False) as temp_pdf_file:
                dashboard_pdf_path = temp_pdf_file.name
            
            # تبدیل اکسل به PDF
            try:
                # اطمینان از اینکه COM در یک thread اصلی اجرا می‌شود
                pythoncom.CoInitialize()
                
                # ایجاد یک نمونه از Excel
                excel = win32com.client.Dispatch("Excel.Application")
                excel.Visible = False
                
                # باز کردن فایل اکسل
                workbook = excel.Workbooks.Open(dashboard_excel_path)
                
                # تنظیم مسیر خروجی PDF
                output_path = os.path.abspath(dashboard_pdf_path)
                
                # تبدیل به PDF
                workbook.ExportAsFixedFormat(0, output_path)
                
                # بستن فایل و خروج از Excel
                workbook.Close(False)
                excel.Quit()
                
                # آزادسازی منابع COM
                del workbook
                del excel
                pythoncom.CoUninitialize()
                
                # ارسال فایل PDF
                with open(dashboard_pdf_path, 'rb') as file:
                    file_name = f"{report_name}_{current_time}.pdf"
                    send_document_with_retry(
                        chat_id,
                        file,
                        caption=f"داشبورد «{report_name}»\nتاریخ: {datetime.now().strftime('%Y/%m/%d %H:%M:%S')}",
                        visible_file_name=file_name
                    )
                
                # پاکسازی فایل موقت PDF
                try:
                    os.unlink(dashboard_pdf_path)
                except Exception as e:
                    logger.error(f"خطا در حذف فایل موقت PDF: {e}")
                
            except Exception as e:
                logger.error(f"خطا در تبدیل اکسل به PDF: {e}")
                send_message_with_retry(chat_id, "خطا در تبدیل داشبورد به PDF. در حال ارسال نسخه اکسل...")
                
                # در صورت خطا در تبدیل، فایل اکسل را ارسال می‌کنیم
                with open(dashboard_excel_path, 'rb') as file:
                    file_name = f"{report_name}_{current_time}.xlsx"
                    send_document_with_retry(
                        chat_id,
                        file,
                        caption=f"داشبورد «{report_name}» (نسخه اکسل)\nتاریخ: {datetime.now().strftime('%Y/%m/%d %H:%M:%S')}",
                        visible_file_name=file_name
                    )
        else:
            # ارسال فایل اکسل
            with open(dashboard_excel_path, 'rb') as file:
                file_name = f"{report_name}_{current_time}.xlsx"
                send_document_with_retry(
                    chat_id,
                    file,
                    caption=f"داشبورد «{report_name}»\nتاریخ: {datetime.now().strftime('%Y/%m/%d %H:%M:%S')}",
                    visible_file_name=file_name
                )
        
        # بازگشت به منوی دسته‌بندی‌ها
        markup = types.InlineKeyboardMarkup(row_width=2)
        markup.add(types.InlineKeyboardButton("🔙 بازگشت به منوی اصلی", callback_data="back_to_categories"))
        
        send_message_with_retry(
            chat_id,
            "داشبورد با موفقیت ارسال شد. آیا می‌خواهید گزارش دیگری دریافت کنید؟",
            reply_markup=markup
        )
        
        # پاکسازی پارامترها
        if 'parameters' in user_data[telegram_id]:
            user_data[telegram_id]['parameters'] = {}
        
        # تنظیم وضعیت کاربر
        user_states[telegram_id] = States.IDLE
        
    except Exception as e:
        logger.error(f"خطا در ارسال داشبورد: {e}")
        
        # ارسال پیام خطای عمومی
        markup = types.InlineKeyboardMarkup()
        markup.add(types.InlineKeyboardButton("🔄 تلاش مجدد", callback_data=f"rep_{user_data[telegram_id]['current_report']['id']}"))
        markup.add(types.InlineKeyboardButton("🔙 بازگشت به لیست گزارش‌ها", callback_data=f"back_to_reports_{user_data[telegram_id]['current_category']}"))
        
        send_message_with_retry(
            chat_id, 
            f"خطا در ارسال داشبورد: {str(e)}\n\nلطفاً دوباره تلاش کنید یا با پشتیبانی تماس بگیرید.",
            reply_markup=markup
        )

# دستور راهنما
@bot.message_handler(commands=['help'])
def help_command(message):
    help_text = """
🔍 راهنمای ربات گزارش‌گیری:

/start - شروع کار با ربات و نمایش منوی اصلی
/help - نمایش این راهنما

📊 برای دریافت گزارش:
1. ابتدا دسته‌بندی مورد نظر را انتخاب کنید
2. سپس گزارش مورد نظر را انتخاب کنید
3. در صورت نیاز، پارامترهای درخواستی را وارد کنید
4. گزارش به صورت فایل اکسل برای شما ارسال می‌شود

⚠️ توجه: شما فقط به گزارش‌هایی دسترسی دارید که برای شما تعریف شده است.
"""
    reply_to_with_retry(message, help_text)

# دستور لغو عملیات فعلی
@bot.message_handler(commands=['cancel'])
def cancel_command(message):
    telegram_id = str(message.from_user.id)
    
    if telegram_id in user_states:
        user_states[telegram_id] = States.IDLE
        
        if telegram_id in user_data and 'parameters' in user_data[telegram_id]:
            user_data[telegram_id]['parameters'] = {}
        
        markup = types.InlineKeyboardMarkup()
        markup.add(types.InlineKeyboardButton("🔄 شروع مجدد", callback_data="restart"))
        
        reply_to_with_retry(
            message,
            "عملیات فعلی لغو شد. برای شروع مجدد از دستور /start استفاده کنید.",
            reply_markup=markup
        )
    else:
        reply_to_with_retry(message, "هیچ عملیاتی در حال انجام نیست.")

# پردازش دکمه شروع مجدد
@bot.callback_query_handler(func=lambda call: call.data == "restart")
def restart_handler(call):
    answer_callback_query_with_retry(call.id)
    try:
        bot.delete_message(call.message.chat.id, call.message.message_id)
    except:
        logger.error("خطا در حذف پیام")
    start_command(call.message)

# پردازش پیام‌های ناشناخته
@bot.message_handler(func=lambda message: True)
def unknown_message(message):
    telegram_id = str(message.from_user.id)
    
    if telegram_id in user_states and user_states[telegram_id] == States.WAITING_FOR_PARAMETERS:
        # پیام احتمالاً یک پارامتر است، آن را به تابع مربوطه ارجاع می‌دهیم
        process_parameter_input(message)
    else:
        markup = types.InlineKeyboardMarkup()
        markup.add(types.InlineKeyboardButton("🔄 شروع ربات", callback_data="restart"))
        
        reply_to_with_retry(
            message,
            "دستور نامشخص. برای شروع کار با ربات از دستور /start استفاده کنید.",
            reply_markup=markup
        )

# تابع بررسی اتصال به اینترنت
def check_internet_connection():
    try:
        # تلاش برای اتصال به API تلگرام
        requests.get('https://api.telegram.org', timeout=5)
        return True
    except:
        return False

# تابع اصلی با مکانیزم تلاش مجدد برای اجرای ربات
def run_bot_with_retry():
    while True:
        try:
            logger.info("ربات گزارش‌گیری در حال شروع...")
            bot.infinity_polling(timeout=60, long_polling_timeout=60)
        except Exception as e:
            logger.error(f"خطا در اجرای ربات: {e}")
            logger.info("تلاش مجدد برای اتصال در 10 ثانیه...")
            time.sleep(10)

# شروع ربات با مکانیزم مقاوم در برابر قطعی
if __name__ == "__main__":
    try:
        # ایجاد فایل PID برای نظارت بر اجرای ربات
        with open('bot.pid', 'w') as f:
            f.write(str(os.getpid()))
        
        logger.info("ربات گزارش‌گیری شروع به کار کرد.")
        run_bot_with_retry()
    except KeyboardInterrupt:
        logger.info("ربات با دستور کاربر متوقف شد.")
    except Exception as e:
        logger.critical(f"خطای بحرانی در اجرای ربات: {e}")
        sys.exit(1)
