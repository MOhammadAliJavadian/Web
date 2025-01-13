import random
import sqlite3
import telebot
import requests
import csv
import time
import logging
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor
from requests.adapters import HTTPAdapter
from telebot import types
import numpy as np
import pandas as pd
import threading
from scipy import signal


class MarketAnalyzer:
    def __init__(self, token):
        # راه‌اندازی دیتابیس
        self.db = UserDatabase()

        # راه‌اندازی سیستم لاگینگ
        self.logger = self.setup_logging()

        # تنظیمات اتصال و سشن
        self.session = self._create_session()
        self.bot = telebot.TeleBot(token)
        self.data_cache = {}  # اضافه کردن این خط
        self.sentiment_cache = {}
        # تنظیم هندلرها
        self.setup_handlers()

        # پارامترهای پیش‌فرض
        self.MIN_GAP_PERCENTAGE = 0.2
        self.BASE_THRESHOLD = 0.1
        self.logger.info("Market Analyzer initialized successfully")
        self.clean_timer = threading.Timer(300.0, self.clean_cache)  # هر 5 دقیقه
    
    def clean_cache(self):
        """پاکسازی کش‌های قدیمی"""
        current_time = time.time()
        
        # پاکسازی کش داده‌ها
        self.data_cache = {
            k: v for k, v in self.data_cache.items() 
            if current_time - v['timestamp'] < 300
        }
        
        # پاکسازی کش سنتیمنت
        self.sentiment_cache = {
            k: v for k, v in self.sentiment_cache.items()
            if current_time - v['timestamp'] < 300
        }

    def _create_session(self):
        session = requests.Session()
        session.headers.update({'User-Agent': 'Mozilla/5.0'})
        adapter = HTTPAdapter(pool_connections=10, pool_maxsize=20, pool_block=True)
        session.mount('https://', adapter)
        return session

    def setup_handlers(self):
        @self.bot.message_handler(commands=['start'])
        def start(message):
            markup = types.InlineKeyboardMarkup(row_width=2)
            options = [
                types.InlineKeyboardButton("تحلیل گپ 📊", callback_data="mode_gap"),
                types.InlineKeyboardButton("تحلیل بیس 📈", callback_data="mode_base"),
                types.InlineKeyboardButton("واگرایی 📉", callback_data="mode_divergence"),
                types.InlineKeyboardButton("دوقلو 🔄", callback_data="mode_double"),
                types.InlineKeyboardButton("مثلث 📐", callback_data="mode_triangle"),
                types.InlineKeyboardButton("اسپایک 📌", callback_data="mode_spike"),
                types.InlineKeyboardButton("شخصی‌سازی 👤", callback_data="personalization")
            ]
            markup.add(*options)

            self.bot.send_message(
                message.chat.id,
                "🤖 به تحلیلگر بازار خوش آمدید!\n"
                "📌 لطفاً نوع تحلیل را انتخاب کنید:",
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data.startswith('mode_'))
        def handle_mode(call):
            mode = call.data.split('_')[1]

            markup = types.InlineKeyboardMarkup(row_width=3)
            timeframes = [
                types.InlineKeyboardButton("15 دقیقه", callback_data=f"{mode}_15m"),
                types.InlineKeyboardButton("30 دقیقه", callback_data=f"{mode}_30m"),
                types.InlineKeyboardButton("1 ساعت", callback_data=f"{mode}_1h"),
                types.InlineKeyboardButton("2 ساعت", callback_data=f"{mode}_2h"),
                types.InlineKeyboardButton("4 ساعت", callback_data=f"{mode}_4h"),
                types.InlineKeyboardButton("روزانه", callback_data=f"{mode}_1d")
            ]
            markup.add(*timeframes)

            mode_texts = {
                "gap": "گپ",
                "base": "بیس",
                "divergence": "واگرایی",
                "double": "دوقلو",
                "triangle": "مثلث",
                "spike": "اسپایک"
            }

            mode_text = mode_texts.get(mode, "نامشخص")

            self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text=f"📊 تحلیل {mode_text}\n"
                     f"⏰ لطفاً تایم‌فریم مورد نظر را انتخاب کنید:",
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data.startswith(
            ('gap_', 'base_', 'divergence_', 'double_', 'triangle_', 'spike_')))
        def handle_query(call):
            mode, timeframe = call.data.split('_')

            self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text=f"🔍 در حال تحلیل {mode} در تایم‌فریم {timeframe}..."
            )

            analysis_methods = {
                "gap": self.analyze_gaps,
                "base": self.analyze_base,
                "divergence": self.analyze_divergence,
                "double": self.analyze_double,
                "triangle": self.analyze_triangle,
                "spike": self.analyze_spikes
            }

            if mode in analysis_methods:
                analysis_methods[mode](call.message.chat.id, timeframe)

        @self.bot.callback_query_handler(func=lambda call: call.data == "personalization")
        def handle_personalization(call):
            markup = types.InlineKeyboardMarkup(row_width=2)
            options = [
                types.InlineKeyboardButton("لیست ارزهای منتخب 📋", callback_data="pers_list"),
                types.InlineKeyboardButton("افزودن ارز جدید ➕", callback_data="pers_add"),
                types.InlineKeyboardButton("مدیریت لیست ⚙️", callback_data="pers_manage"),
                types.InlineKeyboardButton("تنظیمات شخصی ⚡️", callback_data="pers_settings"),
                types.InlineKeyboardButton("بازگشت 🔙", callback_data="back_to_main")
            ]
            markup.add(*options)

            self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text="🎯 به بخش شخصی‌سازی خوش آمدید\n"
                     "📍 لطفا یکی از گزینه‌های زیر را انتخاب کنید:",
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data == "pers_list")
        def handle_coin_list(call):
            user_id = call.message.chat.id
            coins = self.db.get_user_coins(user_id)

            if not coins:
                markup = types.InlineKeyboardMarkup()
                markup.add(
                    types.InlineKeyboardButton("افزودن ارز ➕", callback_data="pers_add"),
                    types.InlineKeyboardButton("بازگشت 🔙", callback_data="personalization")
                )
                self.bot.edit_message_text(
                    chat_id=call.message.chat.id,
                    message_id=call.message.message_id,
                    text="📋 لیست شما خالی است!\n"
                         "برای شروع یک ارز اضافه کنید.",
                    reply_markup=markup
                )
                return

            # گروه‌بندی ارزها
            grouped_coins = {}
            for coin in coins:
                group = coin['group_name']
                if group not in grouped_coins:
                    grouped_coins[group] = []
                grouped_coins[group].append(coin)

            # ساخت پیام با فرمت جدید
            message = "📊 لیست ارزهای منتخب شما:\n\n"
            for group, coins in grouped_coins.items():
                message += f"📁 گروه {group}:\n\n"
                for coin in coins:
                    price = self.get_current_price(coin['symbol'])
                    change = self.get_24h_change(coin['symbol'])
                    message += (
                        f"🔸 {coin['symbol']}/USDT\n"
                        f"قیمت فعلی: {price:.8f} USDT\n"
                        f"تغییرات 24 ساعته: {'+' if change >= 0 else ''}{change:.2f}%\n\n"
                    )

            markup = types.InlineKeyboardMarkup()
            markup.add(
                types.InlineKeyboardButton("بروزرسانی 🔄", callback_data="refresh_list"),
                types.InlineKeyboardButton("مدیریت ⚙️", callback_data="pers_manage"),
                types.InlineKeyboardButton("بازگشت 🔙", callback_data="personalization")
            )

            self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text=message,
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data == "pers_add")
        def handle_add_coin(call):
            markup = types.InlineKeyboardMarkup(row_width=3)

            # دریافت 50 ارز برتر
            top_coins = self.get_top_50_symbols()

            # ساخت دکمه برای هر ارز
            coin_buttons = []
            for coin in top_coins:
                coin_buttons.append(
                    types.InlineKeyboardButton(
                        coin.replace('USDT', ''),
                        callback_data=f"add_coin_{coin}"
                    )
                )

            # اضافه کردن دکمه‌ها به مارکاپ
            markup.add(*coin_buttons)

            # دکمه جستجو و بازگشت
            markup.add(
                types.InlineKeyboardButton("جستجوی دستی 🔍", callback_data="search_coin"),
                types.InlineKeyboardButton("بازگشت 🔙", callback_data="personalization")
            )

            self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text="🎯 لطفاً ارز مورد نظر خود را انتخاب کنید:\n"
                     "یا از طریق جستجوی دستی اقدام کنید.",
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data.startswith("add_coin_"))
        def handle_coin_selection(call):
            coin = call.data.replace("add_coin_", "")
            user_id = call.message.chat.id

            # افزودن به دیتابیس
            success = self.db.add_user_coin(user_id, coin)

            if success:
                message = f"✅ {coin} با موفقیت به لیست شما اضافه شد!"
            else:
                message = f"⚠️ {coin} قبلاً در لیست شما وجود دارد!"

            markup = types.InlineKeyboardMarkup()
            markup.add(
                types.InlineKeyboardButton("افزودن ارز دیگر ➕", callback_data="pers_add"),
                types.InlineKeyboardButton("مشاهده لیست 📋", callback_data="pers_list"),
                types.InlineKeyboardButton("بازگشت 🔙", callback_data="personalization")
            )

            self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text=message,
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data == "pers_manage")
        def handle_manage_list(call):
            user_id = call.message.chat.id
            coins = self.db.get_user_coins(user_id)

            if not coins:
                markup = types.InlineKeyboardMarkup()
                markup.add(
                    types.InlineKeyboardButton("افزودن ارز ➕", callback_data="pers_add"),
                    types.InlineKeyboardButton("بازگشت 🔙", callback_data="personalization")
                )
                self.bot.edit_message_text(
                    chat_id=call.message.chat.id,
                    message_id=call.message.message_id,
                    text="📋 لیست شما خالی است!",
                    reply_markup=markup
                )
                return

            markup = types.InlineKeyboardMarkup(row_width=2)

            # دکمه‌های مدیریتی برای هر ارز
            for coin in coins:
                markup.add(
                    types.InlineKeyboardButton(
                        f"❌ {coin['symbol']}",
                        callback_data=f"remove_coin_{coin['symbol']}"
                    ),
                    types.InlineKeyboardButton(
                        f"📊 {coin['group_name']}",
                        callback_data=f"change_group_{coin['symbol']}"
                    )
                )

            # دکمه‌های کنترلی
            markup.add(
                types.InlineKeyboardButton("گروه جدید ➕", callback_data="new_group"),
                types.InlineKeyboardButton("حذف گروه ➖", callback_data="delete_group"),
                types.InlineKeyboardButton("بازگشت 🔙", callback_data="personalization")
            )

            self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text="⚙️ مدیریت لیست ارزها:\n\n"
                     "• برای حذف ارز روی ❌ کلیک کنید\n"
                     "• برای تغییر گروه روی 📊 کلیک کنید",
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data == "pers_settings")
        def handle_settings(call):
            user_id = call.message.chat.id
            settings = self.db.get_user_settings(user_id)

            markup = types.InlineKeyboardMarkup(row_width=2)

            # تنظیمات تایم‌فریم
            markup.add(
                types.InlineKeyboardButton(
                    f"⏰ تایم‌فریم: {settings['timeframe']}",
                    callback_data="change_timeframe"
                )
            )

            # تنظیمات حساسیت
            markup.add(
                types.InlineKeyboardButton(
                    f"📊 حساسیت گپ: {settings['gap_threshold']}%",
                    callback_data="change_gap"
                ),
                types.InlineKeyboardButton(
                    f"📈 حساسیت اسپایک: {settings['spike_threshold']}%",
                    callback_data="change_spike"
                )
            )

            # تنظیمات اعلان‌ها
            notification_status = "فعال ✅" if settings['notifications'] else "غیرفعال ❌"
            markup.add(
                types.InlineKeyboardButton(
                    f"🔔 اعلان‌ها: {notification_status}",
                    callback_data="toggle_notifications"
                )
            )

            # دکمه‌های کنترلی
            markup.add(
                types.InlineKeyboardButton("بازنشانی ♻️", callback_data="reset_settings"),
                types.InlineKeyboardButton("بازگشت 🔙", callback_data="personalization")
            )

            message = (
                "⚙️ تنظیمات شخصی:\n\n"
                "• برای تغییر هر تنظیم روی آن کلیک کنید\n"
                "• تنظیمات فعلی شما:\n"
                f"- تایم‌فریم پیش‌فرض: {settings['timeframe']}\n"
                f"- حساسیت تشخیص گپ: {settings['gap_threshold']}%\n"
                f"- حساسیت تشخیص اسپایک: {settings['spike_threshold']}%\n"
                f"- وضعیت اعلان‌ها: {notification_status}"
            )

            self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text=message,
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data == "reset_settings")
        def handle_reset_settings(call):
            user_id = call.message.chat.id

            # تنظیمات پیش‌فرض
            default_settings = {
                'timeframe': '1h',
                'gap_threshold': 0.2,
                'spike_threshold': 1.5,
                'notifications': 1
            }

            # بازنشانی تنظیمات در دیتابیس
            self.db.update_user_settings(
                user_id,
                default_settings['timeframe'],
                default_settings['gap_threshold'],
                default_settings['spike_threshold'],
                default_settings['notifications']
            )

            # نمایش پیام موفقیت
            self.bot.answer_callback_query(
                call.id,
                "✅ تنظیمات با موفقیت به حالت پیش‌فرض بازگشت"
            )

            # بروزرسانی منو
            self.handle_settings(call)

        @self.bot.callback_query_handler(func=lambda call: call.data == "change_spike")
        def handle_change_spike(call):
            markup = types.InlineKeyboardMarkup(row_width=3)

            # دکمه‌های درصد حساسیت
            spike_options = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5]
            buttons = []
            for value in spike_options:
                buttons.append(
                    types.InlineKeyboardButton(
                        f"{value}%",
                        callback_data=f"set_spike_{value}"
                    )
                )
            markup.add(*buttons)

            # دکمه بازگشت
            markup.add(types.InlineKeyboardButton("بازگشت 🔙", callback_data="pers_settings"))

            self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text="🎯 درصد حساسیت اسپایک را انتخاب کنید:",
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data == "change_gap")
        def handle_change_gap(call):
            markup = types.InlineKeyboardMarkup(row_width=2)
            gap_options = [
                ("0.2%", "0.2"),
                ("0.3%", "0.3"),
                ("0.5%", "0.5"),
                ("0.7%", "0.7"),
                ("1.0%", "1.0")
            ]

            buttons = [
                types.InlineKeyboardButton(text, callback_data=f"set_gap_{value}")
                for text, value in gap_options
            ]
            markup.add(*buttons)
            markup.add(types.InlineKeyboardButton("بازگشت 🔙", callback_data="pers_settings"))

            self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text="🎯 لطفا حساسیت تشخیص گپ را انتخاب کنید:\n\n"
                     "• مقدار کمتر = حساسیت بیشتر\n"
                     "• مقدار بیشتر = اعلان‌های کمتر",
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data.startswith("set_gap_"))
        def handle_set_gap(call):
            try:
                user_id = call.message.chat.id
                current_settings = self.db.get_user_settings(user_id)
                new_threshold = float(call.data.split('_')[2])

                # آپدیت با حفظ سایر تنظیمات
                self.db.update_user_settings(
                    user_id=user_id,
                    timeframe=current_settings['timeframe'],
                    gap_threshold=new_threshold,
                    spike_threshold=current_settings['spike_threshold'],
                    notifications=current_settings['notifications']
                )

                self.bot.answer_callback_query(call.id, f"✅ حساسیت گپ به {new_threshold}% تغییر کرد")
                self.handle_settings(call)

            except Exception as e:
                print(f"Debug - Error in handle_set_gap: {e}")
                self.bot.answer_callback_query(call.id, "❌ خطا در تغییر حساسیت گپ")

        @self.bot.callback_query_handler(func=lambda call: call.data.startswith("set_spike_"))
        def handle_set_spike(call):
            value = float(call.data.split('_')[2])
            user_id = call.message.chat.id

            # ذخیره مقدار جدید در دیتابیس
            self.db.update_spike_threshold(user_id, value)

            # نمایش مجدد منوی تنظیمات
            settings = self.db.get_user_settings(user_id)
            notification_status = "فعال ✅" if settings['notifications'] else "غیرفعال ❌"

            markup = types.InlineKeyboardMarkup(row_width=2)
            markup.add(
                types.InlineKeyboardButton(
                    f"⏰ تایم‌فریم: {settings['timeframe']}",
                    callback_data="change_timeframe"
                )
            )
            markup.add(
                types.InlineKeyboardButton(
                    f"📊 حساسیت گپ: {settings['gap_threshold']}%",
                    callback_data="change_gap"
                ),
                types.InlineKeyboardButton(
                    f"📈 حساسیت اسپایک: {settings['spike_threshold']}%",
                    callback_data="change_spike"
                )
            )
            markup.add(
                types.InlineKeyboardButton(
                    f"🔔 اعلان‌ها: {notification_status}",
                    callback_data="toggle_notifications"
                )
            )
            markup.add(
                types.InlineKeyboardButton("بازنشانی ♻️", callback_data="reset_settings"),
                types.InlineKeyboardButton("بازگشت 🔙", callback_data="personalization")
            )

            message = (
                "⚙️ تنظیمات شخصی:\n\n"
                "• برای تغییر هر تنظیم روی آن کلیک کنید\n"
                "• تنظیمات فعلی شما:\n"
                f"- تایم‌فریم پیش‌فرض: {settings['timeframe']}\n"
                f"- حساسیت تشخیص گپ: {settings['gap_threshold']}%\n"
                f"- حساسیت تشخیص اسپایک: {settings['spike_threshold']}%\n"
                f"- وضعیت اعلان‌ها: {notification_status}"
            )

            self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text=message,
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data == "change_timeframe")
        def handle_timeframe_change(call):
            markup = types.InlineKeyboardMarkup(row_width=3)
            timeframes = [
                ("15 دقیقه", "15m"), ("30 دقیقه", "30m"),
                ("1 ساعت", "1h"), ("2 ساعت", "2h"),
                ("4 ساعت", "4h"), ("روزانه", "1d")
            ]

            buttons = [
                types.InlineKeyboardButton(name, callback_data=f"set_timeframe_{value}")
                for name, value in timeframes
            ]
            markup.add(*buttons)
            markup.add(types.InlineKeyboardButton("بازگشت 🔙", callback_data="pers_settings"))

            self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text="⏰ تایم‌فریم مورد نظر را انتخاب کنید:",
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data.startswith("change_"))
        def handle_threshold_change(call):
            threshold_type = call.data.replace("change_", "")
            markup = types.InlineKeyboardMarkup(row_width=3)

            values = [0.1, 0.2, 0.5, 1.0, 2.0, 5.0]
            buttons = [
                types.InlineKeyboardButton(
                    f"{val}%",
                    callback_data=f"set_{threshold_type}_{val}"
                ) for val in values
            ]

            markup.add(*buttons)
            markup.add(types.InlineKeyboardButton("بازگشت 🔙", callback_data="pers_settings"))

            title = "گپ" if threshold_type == "gap" else "اسپایک"
            self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text=f"📊 حساسیت تشخیص {title} را انتخاب کنید:",
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data == "toggle_notifications")
        def handle_notifications_toggle(call):
            user_id = call.message.chat.id
            current_status = self.db.get_user_settings(user_id)['notifications']

            # تغییر وضعیت اعلان‌ها
            self.db.update_user_setting(user_id, 'notifications', not current_status)

            # بازگشت به منوی تنظیمات
            handle_settings(call)

        @self.bot.callback_query_handler(func=lambda call: call.data == "reset_settings")
        def handle_reset_settings(self, call):
            try:
                markup = types.InlineKeyboardMarkup()
                markup.add(
                    types.InlineKeyboardButton("بله ✅", callback_data="confirm_reset"),
                    types.InlineKeyboardButton("خیر ❌", callback_data="pers_settings")
                )

                # ابتدا پیام قبلی را حذف می‌کنیم
                self.bot.delete_message(
                    chat_id=call.message.chat.id,
                    message_id=call.message.message_id
                )

                # پیام جدید ارسال می‌کنیم
                self.bot.send_message(
                    chat_id=call.message.chat.id,
                    text="⚠️ آیا از بازنشانی تنظیمات به حالت پیش‌فرض مطمئن هستید؟",
                    reply_markup=markup
                )

            except Exception as e:
                self.bot.answer_callback_query(call.id, "خطا در بازنشانی تنظیمات")

        @self.bot.callback_query_handler(func=lambda call: call.data == "search_coin")
        def handle_manual_search(call):
            markup = types.InlineKeyboardMarkup()
            markup.add(types.InlineKeyboardButton("بازگشت 🔙", callback_data="pers_add"))

            msg = self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text="🔍 نام ارز مورد نظر را وارد کنید:\n"
                     "مثال: BTC یا ETH",
                reply_markup=markup
            )

            # تغییر این خط
            self.bot.register_next_step_handler(msg, lambda m: process_coin_search(self, m))

        def process_coin_search(self, message):
            search_term = message.text.upper()

            # جستجو در لیست ارزها
            found_coins = [coin for coin in self.get_all_symbols()
                           if search_term in coin.replace('USDT', '')]

            markup = types.InlineKeyboardMarkup(row_width=2)

            if not found_coins:
                markup.add(
                    types.InlineKeyboardButton("جستجوی مجدد 🔄", callback_data="search_coin"),
                    types.InlineKeyboardButton("بازگشت 🔙", callback_data="pers_add")
                )
                self.bot.send_message(
                    message.chat.id,
                    "❌ ارزی با این نام یافت نشد!",
                    reply_markup=markup
                )
                return

            # نمایش نتایج جستجو
            for coin in found_coins[:10]:  # نمایش حداکثر 10 نتیجه
                markup.add(types.InlineKeyboardButton(
                    coin.replace('USDT', ''),
                    callback_data=f"add_coin_{coin}"
                ))

            markup.add(types.InlineKeyboardButton("بازگشت 🔙", callback_data="pers_add"))

            self.bot.send_message(
                message.chat.id,
                "🎯 نتایج جستجو:",
                reply_markup=markup
            )

        @self.bot.callback_query_handler(func=lambda call: call.data == "new_group")
        def handle_new_group(call):
            markup = types.InlineKeyboardMarkup()
            markup.add(types.InlineKeyboardButton("بازگشت 🔙", callback_data="pers_manage"))

            msg = self.bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text="📝 نام گروه جدید را وارد کنید:",
                reply_markup=markup
            )

            self.bot.register_next_step_handler(msg, lambda m: process_new_group(self, m))

        def process_new_group(self, message):
            group_name = message.text.strip()
            user_id = message.chat.id

            if len(group_name) > 20:
                text = "❌ نام گروه نباید بیشتر از 20 کاراکتر باشد!"
            else:
                # اضافه کردن گروه جدید به دیتابیس
                self.db.add_group(user_id, group_name)
                text = f"✅ گروه «{group_name}» با موفقیت ایجاد شد!"

            markup = types.InlineKeyboardMarkup()
            markup.add(
                types.InlineKeyboardButton("گروه جدید ➕", callback_data="new_group"),
                types.InlineKeyboardButton("بازگشت 🔙", callback_data="pers_manage")
            )

            self.bot.send_message(message.chat.id, text, reply_markup=markup)

    def setup_logging(self):
        class DatabaseHandler(logging.Handler):
            def __init__(self, db):
                super().__init__()
                self.db = db

            def emit(self, record):
                cursor = self.db.conn.cursor()
                timestamp = datetime.fromtimestamp(record.created).strftime('%Y-%m-%d %H:%M:%S')
                try:
                    cursor.execute("""
                        INSERT INTO logs (timestamp, level, message) 
                        VALUES (?, ?, ?)
                    """, (timestamp, record.levelname, record.getMessage()))
                    self.db.conn.commit()
                except Exception as e:
                    print(f"Error logging to database: {e}")

        # ایجاد و تنظیم logger
        logger = logging.getLogger('MarketAnalyzer')
        logger.setLevel(logging.INFO)

        # حذف هندلرهای قبلی برای جلوگیری از تکرار
        logger.handlers.clear()

        # اضافه کردن هندلر دیتابیس
        db_handler = DatabaseHandler(self.db)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        db_handler.setFormatter(formatter)
        logger.addHandler(db_handler)

        return logger

    def run(self):
        logging.info("ربات شروع به کار کرد...")
        self.bot.infinity_polling()

    def handle_settings(self, call):
        user_id = call.message.chat.id
        settings = self.db.get_user_settings(user_id)

        markup = types.InlineKeyboardMarkup(row_width=2)

        # تنظیمات تایم‌فریم
        markup.add(
            types.InlineKeyboardButton(
                f"⏰ تایم‌فریم: {settings['timeframe']}",
                callback_data="change_timeframe"
            )
        )

        # تنظیمات حساسیت
        markup.add(
            types.InlineKeyboardButton(
                f"📊 حساسیت گپ: {settings['gap_threshold']}%",
                callback_data="change_gap"
            ),
            types.InlineKeyboardButton(
                f"📈 حساسیت اسپایک: {settings['spike_threshold']}%",
                callback_data="change_spike"
            )
        )

        # تنظیمات اعلان‌ها
        notification_status = "فعال ✅" if settings['notifications'] else "غیرفعال ❌"
        markup.add(
            types.InlineKeyboardButton(
                f"🔔 اعلان‌ها: {notification_status}",
                callback_data="toggle_notifications"
            )
        )

        # دکمه‌های کنترلی
        markup.add(
            types.InlineKeyboardButton("بازنشانی ♻️", callback_data="reset_settings"),
            types.InlineKeyboardButton("بازگشت 🔙", callback_data="personalization")
        )

        message = (
            "⚙️ تنظیمات شخصی:\n\n"
            "• برای تغییر هر تنظیم روی آن کلیک کنید\n"
            "• تنظیمات فعلی شما:\n"
            f"- تایم‌فریم پیش‌فرض: {settings['timeframe']}\n"
            f"- حساسیت تشخیص گپ: {settings['gap_threshold']}%\n"
            f"- حساسیت تشخیص اسپایک: {settings['spike_threshold']}%\n"
            f"- وضعیت اعلان‌ها: {notification_status}"
        )

        self.bot.edit_message_text(
            chat_id=call.message.chat.id,
            message_id=call.message.message_id,
            text=message,
            reply_markup=markup
        )

    def get_all_symbols(self):
        # دریافت لیست همه ارزها از بایننس
        exchange_info = self.session.get('https://api.binance.com/api/v3/exchangeInfo').json()
        return [symbol['symbol'] for symbol in exchange_info['symbols']
                if symbol['symbol'].endswith('USDT')]

    def get_current_price(self, symbol):
        try:
            response = self.session.get(f'https://api.binance.com/api/v3/ticker/price?symbol={symbol}')
            data = response.json()
            return float(data['price'])
        except:
            return 0.0

    def get_24h_change(self, symbol):
        try:
            response = self.session.get(f'https://api.binance.com/api/v3/ticker/24hr?symbol={symbol}')
            data = response.json()
            return float(data['priceChangePercent'])
        except:
            return 0.0

    def get_top_50_symbols(self):
        try:
            response = self.session.get('https://api.binance.com/api/v3/ticker/24hr')
            if response.status_code == 200:
                tickers = response.json()
                usdt_pairs = [t for t in tickers if t['symbol'].endswith('USDT')]
                sorted_pairs = sorted(usdt_pairs, key=lambda x: float(x['volume']), reverse=True)
                return [pair['symbol'] for pair in sorted_pairs[:50]]
            return []
        except Exception as e:
            logging.error(f"خطا در دریافت نمادها: {e}")
            return []

    def get_kline_data(self, symbol, timeframe):
        url = 'https://api.binance.com/api/v3/klines'
        params = {'symbol': symbol, 'interval': timeframe, 'limit': 100}
        try:
            response = self.session.get(url, params=params)
            if response.status_code == 200:
                return response.json()
        except Exception as e:
            logging.error(f"خطا در دریافت داده‌های {symbol}: {e}")
        return None

    def find_peaks_numpy(self, arr):
        """یافتن قله‌ها با استفاده از numpy"""
        arr = np.array(arr)
        peaks = []
        for i in range(1, len(arr) - 1):
            if arr[i] > arr[i - 1] and arr[i] > arr[i + 1]:
                peaks.append(i)
        return peaks
    def calculate_rsi(self, prices, period=14):
        """محاسبه RSI با روش دقیق‌تر"""
        if len(prices) < period + 1:
            return []

        # محاسبه تغییرات قیمت
        deltas = np.diff(prices)

        # جداسازی تغییرات مثبت و منفی
        gains = np.where(deltas > 0, deltas, 0)
        losses = np.where(deltas < 0, -deltas, 0)

        # محاسبه میانگین اولیه
        avg_gain = np.mean(gains[:period])
        avg_loss = np.mean(losses[:period])

        # آماده‌سازی آرایه نتایج
        rsi_values = []

        # محاسبه RSI اولیه
        if avg_loss == 0:
            rsi_values.append(100)
        else:
            rs = avg_gain / avg_loss
            rsi_values.append(100 - (100 / (1 + rs)))

        # محاسبه RSI برای نقاط باقیمانده
        for i in range(period, len(gains)):
            avg_gain = ((avg_gain * (period - 1)) + gains[i - 1]) / period
            avg_loss = ((avg_loss * (period - 1)) + losses[i - 1]) / period

            if avg_loss == 0:
                rsi_values.append(100)
            else:
                rs = avg_gain / avg_loss
                rsi_values.append(100 - (100 / (1 + rs)))

        return rsi_values

    def find_peaks(self, data):
        """یافتن قله‌ها در داده"""
        peaks = []
        for i in range(1, len(data) - 1):
            if data[i] > data[i - 1] and data[i] > data[i + 1]:
                peaks.append(i)
        return peaks

    def calculate_trend_slope(self, data):
        """محاسبه شیب خط روند"""
        x = np.arange(len(data))
        slope, _ = np.polyfit(x, data, 1)
        return slope

    def calculate_convergence_point(self, upper_price, lower_price, upper_slope, lower_slope):
        """محاسبه نقطه همگرایی مثلث با اعتبارسنجی"""
        try:
            if abs(upper_slope - lower_slope) < 1e-6:
                return None  # خطوط موازی
                
            x = (lower_price - upper_price) / (upper_slope - lower_slope)
            y = upper_slope * x + upper_price
            
            if x < 0 or y < 0:
                return None  # نقطه همگرایی نامعتبر
                
            return y
        except:
            return None



#gaps
    def analyze_gaps(self, chat_id, timeframe=None):
        self.clean_cache()
        settings = self.db.get_user_settings(chat_id)
        gap_threshold = settings['gap_threshold']
        timeframe = timeframe or settings['timeframe']
        
        user_coins = self.db.get_user_coins(chat_id)
        if not user_coins:
            self.bot.send_message(chat_id, "⚠️ لیست ارزها خالی است")
            return

        self.bot.send_message(
            chat_id, 
            f"🔍 تحلیل گپ با حداقل {gap_threshold}% در تایم‌فریم {timeframe}"
        )

        grouped_results = {}

        for coin in user_coins:
            symbol = coin['symbol']
            group_name = coin['group_name']
            
            # دریافت داده‌های کندل با کش
            kline_data = self.get_cached_kline_data(symbol, timeframe)
            if not kline_data or len(kline_data) < 20:
                continue

            # دریافت سنتیمنت بازار
            market_sentiment = self.get_market_sentiment(symbol)
            
            prices = np.array([float(candle[4]) for candle in kline_data])
            volumes = np.array([float(candle[5]) for candle in kline_data])
            
            volume_sma = self.calculate_sma(volumes, 20)
            pad_length = len(volumes) - len(volume_sma)
            volume_sma = np.pad(volume_sma, (pad_length, 0), 'edge')
            
            rsi = self.calculate_rsi(prices, 14)
            bb_upper, bb_middle, bb_lower = self.calculate_bollinger_bands(prices, 20)

            gaps = []
            for i in range(1, len(kline_data)):
                try:
                    prev_close = float(kline_data[i-1][4])
                    curr_open = float(kline_data[i][1])
                    curr_high = float(kline_data[i][2])
                    curr_low = float(kline_data[i][3])
                    curr_volume = volumes[i]

                    gap_percentage = ((curr_open - prev_close) / prev_close) * 100
                    
                    if abs(gap_percentage) >= gap_threshold:
                        gap_strength = self.calculate_enhanced_gap_strength(
                            gap_percentage,
                            curr_volume / volume_sma[i] if volume_sma[i] > 0 else 0,
                            rsi[i] if i < len(rsi) else 50,
                            curr_open,
                            bb_upper[i] if i < len(bb_upper) else curr_open,
                            market_sentiment
                        )

                        targets = self.calculate_gap_targets(
                            gap_percentage,
                            curr_open,
                            curr_high,
                            curr_low,
                            prev_close
                        )

                        gap_data = {
                            'symbol': symbol,
                            'time': datetime.fromtimestamp(kline_data[i][0] / 1000).strftime('%Y-%m-%d %H:%M'),
                            'gap_percentage': round(gap_percentage, 2),
                            'strength': round(gap_strength, 2),
                            'direction': 'صعودی ⬆️' if gap_percentage > 0 else 'نزولی ⬇️',
                            'targets': targets,
                            'market_sentiment': market_sentiment,
                            'probability': self.calculate_gap_fill_probability(
                                gap_percentage, 
                                curr_volume,
                                volume_sma[i],
                                market_sentiment
                            ),
                            'risk_level': self.calculate_gap_risk(
                                gap_percentage,
                                rsi[i] if i < len(rsi) else 50,
                                curr_volume / volume_sma[i] if volume_sma[i] > 0 else 0,
                                market_sentiment
                            )
                        }
                        gaps.append(gap_data)
                except IndexError:
                    continue

            if gaps:
                if group_name not in grouped_results:
                    grouped_results[group_name] = []
                grouped_results[group_name].extend(gaps)

        if grouped_results:
            self._send_enhanced_gap_results(chat_id, grouped_results)
        else:
            self.bot.send_message(
                chat_id, 
                f"❌ هیچ گپی بزرگتر از {gap_threshold}% در ارزهای انتخابی یافت نشد"
            )
        # برگشت به منوی اصلی
        message = types.Message(
            message_id=None,
            from_user=None,
            date=None,
            chat=types.Chat(id=chat_id, type=None),
            content_type=None,
            options={},
            json_string=None
        )
        self.bot.message_handlers[0]['function'](message)

    def get_market_sentiment(self, symbol):
        """دریافت سنتیمنت بازار با کش"""
        if symbol in self.sentiment_cache:
            cached_data = self.sentiment_cache[symbol]
            if time.time() - cached_data['timestamp'] < 300:  # 5 دقیقه
                return cached_data['data']
        
        sentiment_data = {
            'social_score': self.get_social_sentiment(symbol),
            'news_score': self.get_news_sentiment(symbol),
            'whale_score': self.get_whale_activity(symbol),
            'exchange_flow': self.get_exchange_flows(symbol),
            'total_score': 0
        }
        
        # محاسبه امتیاز کلی
        weights = {'social': 0.3, 'news': 0.3, 'whale': 0.25, 'flow': 0.15}
        sentiment_data['total_score'] = sum([
            sentiment_data['social_score'] * weights['social'],
            sentiment_data['news_score'] * weights['news'],
            sentiment_data['whale_score'] * weights['whale'],
            sentiment_data['exchange_flow'] * weights['flow']
        ])
        
        self.sentiment_cache[symbol] = {
            'data': sentiment_data,
            'timestamp': time.time()
        }
        
        return sentiment_data

    def calculate_enhanced_gap_strength(self, gap_percentage, volume_ratio, rsi, price, bb_upper, sentiment):
        """محاسبه پیشرفته قدرت گپ با سنتیمنت"""
        strength = 0

        # وزن‌دهی به فاکتورها
        gap_weight = min(abs(gap_percentage) * 0.3, 30)  # حداکثر 30 امتیاز
        volume_weight = min(volume_ratio * 15, 25)  # حداکثر 25 امتیاز
        sentiment_weight = min(sentiment['total_score'] * 0.25, 25)  # حداکثر 25 امتیاز

        # تحلیل RSI
        rsi_weight = 0
        if gap_percentage > 0:  # گپ صعودی
            if rsi < 70:
                rsi_weight = 20
            elif rsi < 80:
                rsi_weight = 10
        else:  # گپ نزولی
            if rsi > 30:
                rsi_weight = 20
            elif rsi > 20:
                rsi_weight = 10

        # محاسبه نهایی
        strength = gap_weight + volume_weight + rsi_weight + sentiment_weight

        return min(strength, 100)

    def calculate_gap_targets(self, gap_percentage, curr_open, curr_high, curr_low, prev_close):
        """محاسبه اهداف قیمتی گپ"""
        gap_size = abs(curr_open - prev_close)

        if gap_percentage > 0:
            return {
                'target1': round(curr_open + (gap_size * 0.382), 8),
                'target2': round(curr_open + (gap_size * 0.618), 8),
                'target3': round(curr_open + gap_size, 8)
            }
        else:
            return {
                'target1': round(curr_open - (gap_size * 0.382), 8),
                'target2': round(curr_open - (gap_size * 0.618), 8),
                'target3': round(curr_open - gap_size, 8)
            }

    def calculate_gap_fill_probability(self, gap_percentage, volume, avg_volume, sentiment):
        """محاسبه احتمال پر شدن گپ با سنتیمنت"""
        base_prob = 70

        # تعدیل براساس اندازه گپ
        gap_factor = max(0, 100 - abs(gap_percentage) * 2) / 100

        # تعدیل براساس حجم
        volume_ratio = volume / avg_volume
        volume_factor = min(volume_ratio / 3, 1)

        # تعدیل براساس سنتیمنت
        sentiment_factor = sentiment['total_score'] / 100

        final_prob = base_prob * gap_factor * volume_factor * (1 + sentiment_factor * 0.3)
        return round(min(final_prob, 100), 1)

    def calculate_gap_risk(self, gap_percentage, rsi, volume_ratio, sentiment):
        """محاسبه سطح ریسک گپ با سنتیمنت"""
        risk_score = 0

        # ارزیابی براساس اندازه گپ
        if abs(gap_percentage) > 5:
            risk_score += 35
        elif abs(gap_percentage) > 3:
            risk_score += 20
        else:
            risk_score += 10

        # ارزیابی براساس RSI
        if (gap_percentage > 0 and rsi > 70) or (gap_percentage < 0 and rsi < 30):
            risk_score += 25
        elif (gap_percentage > 0 and rsi > 60) or (gap_percentage < 0 and rsi < 40):
            risk_score += 15

        # ارزیابی براساس حجم
        if volume_ratio > 3:
            risk_score += 25
        elif volume_ratio > 2:
            risk_score += 15
        elif volume_ratio > 1.5:
            risk_score += 10

        # ارزیابی براساس سنتیمنت
        sentiment_score = sentiment['total_score']
        if sentiment_score < 30:
            risk_score += 15
        elif sentiment_score < 50:
            risk_score += 10

        # تعیین سطح ریسک
        if risk_score >= 70:
            return "زیاد"
        elif risk_score >= 40:
            return "متوسط"
        else:
            return "کم"

    def _send_enhanced_gap_results(self, chat_id, grouped_results):
        message = "📊 نتایج تحلیل گپ:\n\n"

        for group_name, gaps in grouped_results.items():
            message += f"📌 گروه {group_name}:\n"
            
            for gap in gaps[:3]:  # نمایش 3 گپ برتر هر گروه
                symbol = gap['symbol']
                strength_emoji = self._get_strength_emoji(gap['strength'])
                probability_emoji = self._get_probability_emoji(gap['probability'])
                
                sentiment_status = self._get_sentiment_status(gap['market_sentiment']['total_score'])
                
                group_message = (
                    f"🔸 {symbol}\n"
                    f"{strength_emoji} گپ {gap['direction']}\n"
                    f"⏰ زمان: {gap['time']}\n"
                    f"📈 درصد گپ: {gap['gap_percentage']}%\n"
                    f"💪 قدرت سیگنال: {gap['strength']}/100\n"
                    f"📊 احتمال پر شدن: {gap['probability']}% {probability_emoji}\n"
                    f"🌊 سنتیمنت بازار: {sentiment_status}\n"
                    f"⚠️ سطح ریسک: {self._format_risk_level(gap['risk_level'])}\n\n"
                    f"🎯 اهداف قیمتی:\n"
                    f"   ①: {gap['targets']['target1']}\n"
                    f"   ②: {gap['targets']['target2']}\n"
                    f"   ③: {gap['targets']['target3']}\n"
                    f"〰️〰️〰️〰️〰️〰️〰️〰️\n"
                )

                if len(message + group_message) > 3800:
                    self.bot.send_message(chat_id, message)
                    message = group_message
                else:
                    message += group_message

        if message:
            self.bot.send_message(chat_id, message)

    def _get_strength_emoji(self, strength):
        if strength >= 80:
            return "🔥"
        elif strength >= 60:
            return "💪"
        elif strength >= 40:
            return "✅"
        else:
            return "⚡"

    def _get_probability_emoji(self, probability):
        if probability >= 75:
            return "✅"
        elif probability >= 50:
            return "📊"
        else:
            return "⚠️"


    def _get_sentiment_status(self, score):
        if score >= 70:
            return "بسیار مثبت 🟢"
        elif score >= 50:
            return "مثبت 🟡"
        elif score >= 30:
            return "خنثی ⚪"
        else:
            return "منفی 🔴"

    def get_cached_kline_data(self, symbol, timeframe):
        """دریافت داده‌های کندل با کش"""
        cache_key = f"{symbol}_{timeframe}"
        if cache_key in self.data_cache:
            cached_data = self.data_cache[cache_key]
            if time.time() - cached_data['timestamp'] < 60:  # 1 دقیقه
                return cached_data['data']
        
        kline_data = self.get_kline_data(symbol, timeframe)
        if kline_data:
            self.data_cache[cache_key] = {
                'data': kline_data,
                'timestamp': time.time()
            }
        return kline_data

    def get_social_sentiment(self, symbol):
        """تحلیل سنتیمنت شبکه‌های اجتماعی"""
        # اینجا می‌تونید API های مختلف رو اضافه کنید
        return random.randint(0, 100)  # فعلا مقدار تصادفی

    def get_news_sentiment(self, symbol):
        """تحلیل سنتیمنت اخبار"""
        return random.randint(0, 100)  # فعلا مقدار تصادفی

    def get_whale_activity(self, symbol):
        """تحلیل فعالیت نهنگ‌ها"""
        return random.randint(0, 100)  # فعلا مقدار تصادفی

    def get_exchange_flows(self, symbol):
        """تحلیل جریان ورود و خروج صرافی‌ها"""
        return random.randint(0, 100)  # فعلا مقدار تصادفی


#base
    def analyze_base(self, chat_id, timeframe):
        self.clean_cache()        
        settings = self.db.get_user_settings(chat_id)
        user_coins = self.db.get_user_coins(chat_id)
        
        if not user_coins:
            self.bot.send_message(
                chat_id,
                "⚠️ شما هنوز هیچ ارزی به لیست خود اضافه نکرده‌اید!\n"
                "برای شروع، از منوی شخصی‌سازی ارزهای مورد نظر خود را اضافه کنید."
            )
            return

        self.bot.send_message(chat_id, "🔍 در حال تحلیل بیس‌ها...")
        grouped_results = {}

        for coin in user_coins:
            symbol = coin['symbol']
            group_name = coin['group_name']
            
            # دریافت داده‌ها با کش
            kline_data = self.get_cached_kline_data(symbol, timeframe)
            if not kline_data:
                continue
                
            # دریافت سنتیمنت بازار
            market_sentiment = self.get_market_sentiment(symbol)
            
            bases = self.find_enhanced_base(kline_data, market_sentiment, symbol)
            
            if bases:
                if group_name not in grouped_results:
                    grouped_results[group_name] = []
                grouped_results[group_name].extend(bases)

        if grouped_results:
            self._send_enhanced_base_results(chat_id, grouped_results, timeframe)
        else:
            self.bot.send_message(chat_id, "❌ هیچ بیسی در ارزهای منتخب شما یافت نشد.")
        # برگشت به منوی اصلی
        message = types.Message(
            message_id=None,
            from_user=None,
            date=None,
            chat=types.Chat(id=chat_id, type=None),
            content_type=None,
            options={},
            json_string=None
        )
        self.bot.message_handlers[0]['function'](message)
    def find_enhanced_base(self, data, sentiment, symbol):  # اضافه کردن پارامتر symbol
        """
        تحلیل و شناسایی الگوهای بیس
        
        پارامترها:
        - data: داده‌های کندل
        - sentiment: اطلاعات سنتیمنت بازار
        - symbol: نام ارز
        """
        bases = []
        prices = np.array([float(candle[4]) for candle in data])
        volumes = np.array([float(candle[5]) for candle in data])
        
        # محاسبه اندیکاتورها
        rsi = self.calculate_rsi(prices, 14)
        macd, signal, hist = self.calculate_macd(prices)
        bb_upper, bb_middle, bb_lower = self.calculate_bollinger_bands(prices, 20)
        volume_sma = self.calculate_sma(volumes, 20)
        
        window_size = 20  # پنجره بررسی بیس
        
        for i in range(window_size, len(data)-window_size):
            window = prices[i-window_size:i+window_size]
            volume_window = volumes[i-window_size:i+window_size]
            
            # شناسایی بیس
            if self.is_valid_base(window, volume_window):
                base_data = self.calculate_base_metrics(
                    symbol,  # استفاده مستقیم از نام ارز                    
                    data[i-window_size:i+window_size],
                    prices[i-window_size:i+window_size],
                    volumes[i-window_size:i+window_size],
                    rsi[i],
                    macd[i],
                    signal[i],
                    bb_upper[i],
                    bb_lower[i],
                    sentiment
                )
                bases.append(base_data)
        
        return bases

    def is_valid_base(self, prices, volumes):
        price_range = (max(prices) - min(prices)) / np.mean(prices) * 100
        volume_increase = np.mean(volumes[-5:]) / np.mean(volumes[:-5])
        
        return (
            5 > price_range > 0.5 and  # محدوده نوسان منطقی
            volume_increase > 1.2  # افزایش حجم
        )

    def calculate_base_metrics(self, symbol, candles, prices, volumes, rsi, macd, signal, bb_upper, bb_lower, sentiment):
        support = min(prices)
        resistance = max(prices)
        avg_price = np.mean(prices)
        
        # محاسبه قدرت بیس
        base_strength = self.calculate_base_strength(
            prices, volumes, rsi, macd, signal, 
            bb_upper, bb_lower, sentiment
        )
        
        # محاسبه اهداف قیمتی
        targets = self.calculate_base_targets(support, resistance, sentiment)
        
        # محاسبه احتمال موفقیت
        success_prob = self.calculate_base_probability(
            prices, volumes, rsi, sentiment
        )
        
        return {
            'symbol': symbol,  # Now using the passed symbol parameter
            'start_time': datetime.fromtimestamp(candles[0][0] / 1000).strftime('%Y-%m-%d %H:%M'),
            'end_time': datetime.fromtimestamp(candles[-1][0] / 1000).strftime('%Y-%m-%d %H:%M'),
            'support': support,
            'resistance': resistance,
            'avg_price': avg_price,
            'range_percentage': ((resistance - support) / support) * 100,
            'volume_ratio': np.mean(volumes[-5:]) / np.mean(volumes[:-5]),
            'rsi': rsi,
            'strength': base_strength,
            'targets': targets,
            'success_probability': success_prob,
            'sentiment': sentiment,
            'risk_level': self.calculate_base_risk(
                prices, volumes, rsi, sentiment
            )
        }

    def calculate_base_strength(self, prices, volumes, rsi, macd, signal, bb_upper, bb_lower, sentiment):
        strength = 0
        
        # تحلیل قیمت
        price_range = (max(prices) - min(prices)) / np.mean(prices) * 100
        if 1 < price_range < 3:
            strength += 30
        elif price_range <= 5:
            strength += 20
            
        # تحلیل حجم
        volume_increase = np.mean(volumes[-5:]) / np.mean(volumes[:-5])
        strength += min(volume_increase * 10, 25)
        
        # تحلیل RSI
        if 40 < rsi < 60:
            strength += 15
        
        # تحلیل MACD
        if abs(macd - signal) < 0.0001:
            strength += 15
            
        # تاثیر سنتیمنت
        sentiment_score = sentiment['total_score']
        strength += sentiment_score * 0.15
        
        return min(strength, 100)

    def calculate_base_targets(self, support, resistance, sentiment):
        base_height = resistance - support
        sentiment_factor = sentiment['total_score'] / 100
        
        return {
            'breakout_targets': {
                'target1': round(resistance + (base_height * 0.618), 8),
                'target2': round(resistance + (base_height * 1), 8),
                'target3': round(resistance + (base_height * 1.618 * (1 + sentiment_factor)), 8)
            },
            'breakdown_targets': {
                'target1': round(support - (base_height * 0.618), 8),
                'target2': round(support - (base_height * 1), 8),
                'target3': round(support - (base_height * 1.618 * (1 + sentiment_factor)), 8)
            }
        }

    def calculate_base_probability(self, prices, volumes, rsi, sentiment):
        base_prob = 60
        
        # تحلیل حجم
        volume_ratio = np.mean(volumes[-5:]) / np.mean(volumes[:-5])
        if volume_ratio > 2:
            base_prob += 15
        elif volume_ratio > 1.5:
            base_prob += 10
            
        # تحلیل RSI
        if 40 < rsi < 60:
            base_prob += 10
            
        # تاثیر سنتیمنت
        sentiment_boost = sentiment['total_score'] * 0.15
        base_prob += sentiment_boost
        
        return min(base_prob, 100)

    def calculate_base_risk(self, prices, volumes, rsi, sentiment):
        risk_score = 0
        
        # تحلیل نوسان قیمت
        price_volatility = np.std(prices) / np.mean(prices) * 100
        if price_volatility > 3:
            risk_score += 30
        elif price_volatility > 2:
            risk_score += 20
            
        # تحلیل حجم
        volume_ratio = np.mean(volumes[-5:]) / np.mean(volumes[:-5])
        if volume_ratio > 3:
            risk_score += 25
        elif volume_ratio > 2:
            risk_score += 15
            
        # تحلیل RSI
        if rsi > 70 or rsi < 30:
            risk_score += 25
            
        # تاثیر سنتیمنت منفی
        if sentiment['total_score'] < 40:
            risk_score += 20
            
        if risk_score >= 70:
            return "زیاد"
        elif risk_score >= 40:
            return "متوسط"
        return "کم"

    def _send_enhanced_base_results(self, chat_id, grouped_results, timeframe):
        message = f"📊 نتایج تحلیل بیس در تایم‌فریم {timeframe}:\n\n"

        for group_name, bases in grouped_results.items():
            message += f"📌 گروه {group_name}:\n"
            
            # مرتب‌سازی بر اساس قدرت سیگنال
            sorted_bases = sorted(bases, key=lambda x: x['strength'], reverse=True)
            
            for base in sorted_bases[:3]:  # نمایش 3 بیس برتر هر گروه
                strength_emoji = self._get_strength_emoji(base['strength'])
                probability_emoji = self._get_probability_emoji(base['success_probability'])
                
                base_message = (
                    f"🔸 {base['symbol']}\n"
                    f"{strength_emoji} قدرت سیگنال: {base['strength']}/100\n"
                    f"⏰ دوره زمانی:\n"
                    f"   شروع: {base['start_time']}\n"
                    f"   پایان: {base['end_time']}\n"
                    f"📈 تحلیل تکنیکال:\n"
                    f"   • نوسان: {base['range_percentage']:.2f}%\n"
                    f"   • RSI: {base['rsi']:.1f}\n"
                    f"   • حجم: {base['volume_ratio']:.1f}x\n"
                    f"💫 سنتیمنت بازار:\n"
                    f"   • اجتماعی: {base['sentiment']['social_score']}%\n"
                    f"   • خبری: {base['sentiment']['news_score']}%\n"
                    f"   • نهنگ‌ها: {base['sentiment']['whale_score']}%\n"
                    f"📊 احتمال موفقیت: {base['success_probability']}% {probability_emoji}\n"
                    f"⚠️ سطح ریسک: {self._format_risk_level(base['risk_level'])}\n"
                    f"📍 سطوح کلیدی:\n"
                    f"   • حمایت: {base['support']:.8f}\n"
                    f"   • مقاومت: {base['resistance']:.8f}\n"
                    f"🎯 اهداف صعودی:\n"
                    f"   ①: {base['targets']['breakout_targets']['target1']}\n"
                    f"   ②: {base['targets']['breakout_targets']['target2']}\n"
                    f"   ③: {base['targets']['breakout_targets']['target3']}\n"
                    f"🎯 اهداف نزولی:\n"
                    f"   ①: {base['targets']['breakdown_targets']['target1']}\n"
                    f"   ②: {base['targets']['breakdown_targets']['target2']}\n"
                    f"   ③: {base['targets']['breakdown_targets']['target3']}\n"
                    f"〰️〰️〰️〰️〰️〰️〰️〰️\n"
                )

                if len(message + base_message) > 3800:
                    self.bot.send_message(chat_id, message)
                    message = base_message
                else:
                    message += base_message

        if message:
            self.bot.send_message(chat_id, message)

    def _get_strength_emoji(self, strength):
        """انتخاب ایموجی براساس قدرت سیگنال"""
        if strength >= 80:
            return "🔥"
        elif strength >= 60:
            return "💪"
        elif strength >= 40:
            return "✅"
        return "⚡"


    def calculate_macd(self, prices, fast_period=12, slow_period=26, signal_period=9):
        # تبدیل numpy array به pandas Series
        price_series = pd.Series(prices)
        
        # محاسبه EMA سریع و کند
        exp1 = price_series.ewm(span=fast_period, adjust=False).mean()
        exp2 = price_series.ewm(span=slow_period, adjust=False).mean()
        
        # محاسبه MACD Line
        macd_line = exp1 - exp2
        
        # محاسبه Signal Line
        signal_line = macd_line.ewm(span=signal_period, adjust=False).mean()
        
        # محاسبه MACD Histogram
        macd_hist = macd_line - signal_line
        
        # تبدیل به numpy array برای سازگاری با بقیه کد
        return np.array(macd_line), np.array(signal_line), np.array(macd_hist)

    def _get_probability_emoji(self, probability):
        if probability >= 75:
            return "✅"
        elif probability >= 50:
            return "📊"
        return "⚠️"


#Spike
    def analyze_spikes(self, chat_id, timeframe):
        self.clean_cache()
        """تحلیل پیشرفته اسپایک‌ها در بازار"""
        settings = self.db.get_user_settings(chat_id)
        spike_threshold = settings['spike_threshold']
        
        user_coins = self.db.get_user_coins(chat_id)
        if not user_coins:
            self.bot.send_message(
                chat_id,
                "⚠️ لیست ارزها خالی است"
            )
            return

        self.bot.send_message(
            chat_id, 
            f"🔍 تحلیل اسپایک با حداقل {spike_threshold}% در تایم‌فریم {timeframe}"
        )

        grouped_results = {}

        for coin in user_coins:
            symbol = coin['symbol']
            group_name = coin['group_name']
            
            # دریافت داده‌ها با کش
            kline_data = self.get_cached_kline_data(symbol, timeframe)
            if not kline_data:
                continue
                
            # دریافت سنتیمنت بازار
            market_sentiment = self.get_market_sentiment(symbol)
            
            spikes = self.find_enhanced_spikes(
                kline_data, 
                spike_threshold,
                market_sentiment,
                symbol
            )
            
            if spikes:
                if group_name not in grouped_results:
                    grouped_results[group_name] = []
                grouped_results[group_name].extend(spikes)

        if grouped_results:
            self._send_enhanced_spike_results(chat_id, grouped_results, timeframe)
        else:
            self.bot.send_message(
                chat_id, 
                f"❌ هیچ اسپایکی بزرگتر از {spike_threshold}% یافت نشد"
            )
        # برگشت به منوی اصلی
        message = types.Message(
            message_id=None,
            from_user=None,
            date=None,
            chat=types.Chat(id=chat_id, type=None),
            content_type=None,
            options={},
            json_string=None
        )
        self.bot.message_handlers[0]['function'](message)
    def find_enhanced_spikes(self, data, threshold, sentiment, symbol):
        """تحلیل پیشرفته اسپایک با اندیکاتورها و سنتیمنت"""
        spikes = []
        window_size = 20

        if len(data) < window_size + 1:
            return spikes

        # تبدیل داده‌ها به آرایه numpy
        np_data = np.array([[float(x) for x in candle] for candle in data])
        closes = np_data[:, 4]
        highs = np_data[:, 2]
        lows = np_data[:, 3]
        volumes = np_data[:, 5]
        opens = np_data[:, 1]

        # محاسبه اندیکاتورها
        bb_upper, bb_middle, bb_lower = self.calculate_bollinger_bands(closes, window_size)
        rsi = self.calculate_rsi(closes, window_size)
        macd, signal, hist = self.calculate_macd(closes)
        volume_sma = self.calculate_sma(volumes, window_size)
        
        for i in range(window_size, len(data) - 1):
            idx = i - window_size
            curr_price = closes[i]
            curr_volume = volumes[i]
            
            # محاسبه متریک‌ها
            price_change = ((curr_price - closes[i-1]) / closes[i-1]) * 100
            volume_ratio = curr_volume / volume_sma[idx] if volume_sma[idx] > 0 else 0
            
            # محاسبه محدوده قیمت
            recent_high = max(highs[i-window_size:i])
            recent_low = min(lows[i-window_size:i])
            price_range = recent_high - recent_low

            # شناسایی اسپایک
            is_spike = self.validate_spike(
                price_change,
                threshold,
                volume_ratio,
                curr_price,
                bb_upper[idx],
                bb_lower[idx],
                rsi[idx],
                macd[i],
                signal[i]
            )

            if is_spike:
                spike_strength = self.calculate_spike_strength(
                    price_change,
                    volume_ratio,
                    rsi[idx],
                    sentiment,
                    macd[i] - signal[i]
                )
                
                targets = self.calculate_spike_targets(
                    curr_price,
                    price_range,
                    price_change,
                    sentiment
                )
                
                risk_level = self.calculate_spike_risk(
                    price_change,
                    volume_ratio,
                    rsi[idx],
                    sentiment
                )
                
                success_prob = self.calculate_spike_probability(
                    price_change,
                    volume_ratio,
                    rsi[idx],
                    sentiment
                )

                spike_data = {
                    'symbol': symbol,
                    'time': datetime.fromtimestamp(data[i][0] / 1000).strftime('%Y-%m-%d %H:%M'),
                    'direction': "صعودی 📈" if price_change > 0 else "نزولی 📉",
                    'price_change': round(price_change, 2),
                    'volume_ratio': round(volume_ratio, 2),
                    'price': float(curr_price),
                    'rsi': float(rsi[idx]),
                    'strength': spike_strength,
                    'targets': targets,
                    'risk_level': risk_level,
                    'success_probability': success_prob,
                    'sentiment': sentiment
                }
                spikes.append(spike_data)

        return sorted(spikes, key=lambda x: x['strength'], reverse=True)

    def validate_spike(self, price_change, threshold, volume_ratio, price, bb_upper, bb_lower, rsi, macd, signal):
        """اعتبارسنجی اسپایک با شرایط پیشرفته"""
        return (
            abs(price_change) >= threshold and
            volume_ratio > 1.5 and
            (price > bb_upper or price < bb_lower) and
            (rsi > 70 or rsi < 30) and
            abs(macd - signal) > 0.0001
        )

    def calculate_spike_strength(self, price_change, volume_ratio, rsi, sentiment, macd_diff):
        """محاسبه قدرت اسپایک"""
        strength = 0
        
        # وزن‌دهی به فاکتورها
        price_weight = min(abs(price_change) * 0.3, 30)
        volume_weight = min(volume_ratio * 15, 25)
        sentiment_weight = min(sentiment['total_score'] * 0.25, 25)
        
        # تحلیل RSI
        rsi_weight = 0
        if price_change > 0:  # اسپایک صعودی
            if rsi > 80:
                rsi_weight = 10
            elif rsi > 70:
                rsi_weight = 20
        else:  # اسپایک نزولی
            if rsi < 20:
                rsi_weight = 10
            elif rsi < 30:
                rsi_weight = 20
                
        # تاثیر MACD
        macd_weight = min(abs(macd_diff) * 10, 10)
        
        strength = price_weight + volume_weight + rsi_weight + sentiment_weight + macd_weight
        return min(strength, 100)

    def calculate_spike_targets(self, price, price_range, price_change, sentiment):
        """محاسبه اهداف قیمتی اسپایک"""
        sentiment_factor = sentiment['total_score'] / 100
        
        if price_change > 0:
            return {
                'target1': round(price + (price_range * 0.382), 8),
                'target2': round(price + (price_range * 0.618), 8),
                'target3': round(price + (price_range * (1 + sentiment_factor)), 8),
                'stop_loss': round(price - (price_range * 0.236), 8)
            }
        else:
            return {
                'target1': round(price - (price_range * 0.382), 8),
                'target2': round(price - (price_range * 0.618), 8),
                'target3': round(price - (price_range * (1 + sentiment_factor)), 8),
                'stop_loss': round(price + (price_range * 0.236), 8)
            }

    def calculate_spike_probability(self, price_change, volume_ratio, rsi, sentiment):
        """محاسبه احتمال موفقیت اسپایک"""
        base_prob = 60
        
        # تعدیل براساس تغییر قیمت
        price_factor = max(0, 100 - abs(price_change)) / 100
        
        # تعدیل براساس حجم
        volume_factor = min(volume_ratio / 3, 1)
        
        # تعدیل براساس RSI
        rsi_factor = 1
        if price_change > 0 and rsi > 80:
            rsi_factor = 0.8
        elif price_change < 0 and rsi < 20:
            rsi_factor = 0.8
            
        # تعدیل براساس سنتیمنت
        sentiment_factor = sentiment['total_score'] / 100
        
        final_prob = base_prob * price_factor * volume_factor * rsi_factor * (1 + sentiment_factor * 0.3)
        return round(min(final_prob, 100), 1)

    def calculate_spike_risk(self, price_change, volume_ratio, rsi, sentiment):
        """محاسبه سطح ریسک اسپایک"""
        risk_score = 0
        
        # ارزیابی براساس تغییر قیمت
        if abs(price_change) > 10:
            risk_score += 35
        elif abs(price_change) > 5:
            risk_score += 25
        else:
            risk_score += 15
            
        # ارزیابی براساس حجم
        if volume_ratio > 5:
            risk_score += 25
        elif volume_ratio > 3:
            risk_score += 15
        
        # ارزیابی براساس RSI
        if (price_change > 0 and rsi > 85) or (price_change < 0 and rsi < 15):
            risk_score += 25
        elif (price_change > 0 and rsi > 75) or (price_change < 0 and rsi < 25):
            risk_score += 15
            
        # ارزیابی براساس سنتیمنت
        if sentiment['total_score'] < 30:
            risk_score += 15
            
        if risk_score >= 70:
            return "زیاد"
        elif risk_score >= 40:
            return "متوسط"
        return "کم"
    
    def calculate_bollinger_bands(self, prices, window):
        """محاسبه باندهای بولینگر"""
        prices = np.array(prices)
        
        # محاسبه میانگین متحرک
        sma = np.zeros(len(prices))
        for i in range(window - 1, len(prices)):
            sma[i] = np.mean(prices[i - window + 1:i + 1])
        
        # محاسبه انحراف معیار
        std = np.zeros(len(prices))
        for i in range(window - 1, len(prices)):
            std[i] = np.std(prices[i - window + 1:i + 1])
        
        # محاسبه باندها
        upper_band = sma + (std * 2)
        lower_band = sma - (std * 2)
        
        return upper_band, sma, lower_band
    
    def calculate_sma(self, data, window):
        """محاسبه میانگین متحرک ساده"""
        data = np.array(data)
        weights = np.ones(window)
        sma = np.convolve(data, weights/weights.sum(), mode='valid')
        # پر کردن مقادیر اولیه با صفر برای حفظ طول آرایه
        padding = np.zeros(window-1)
        return np.concatenate((padding, sma))

    def _send_enhanced_spike_results(self, chat_id, grouped_results, timeframe):
        """ارسال نتایج پیشرفته تحلیل اسپایک"""
        message = f"📊 نتایج تحلیل اسپایک در تایم‌فریم {timeframe}:\n\n"

        for group_name, spikes in grouped_results.items():
            message += f"📌 گروه {group_name}:\n"
            
            for spike in spikes[:3]:  # نمایش 3 اسپایک برتر هر گروه
                strength_emoji = self._get_strength_emoji(spike['strength'])
                probability_emoji = self._get_probability_emoji(spike['success_probability'])
                
                sentiment_status = self._get_sentiment_status(spike['sentiment']['total_score'])
                
                spike_message = (
                    f"🔸 {spike['symbol']}\n"
                    f"{strength_emoji} اسپایک {spike['direction']}\n"
                    f"⏰ زمان: {spike['time']}\n"
                    f"📈 تغییر قیمت: {spike['price_change']}%\n"
                    f"💪 قدرت سیگنال: {spike['strength']}/100\n"
                    f"📊 احتمال موفقیت: {spike['success_probability']}% {probability_emoji}\n"
                    f"🌊 سنتیمنت بازار: {sentiment_status}\n"
                    f"⚠️ سطح ریسک: {self._format_risk_level(spike['risk_level'])}\n\n"
                    f"🎯 اهداف قیمتی:\n"
                    f"   ①: {spike['targets']['target1']}\n"
                    f"   ②: {spike['targets']['target2']}\n"
                    f"   ③: {spike['targets']['target3']}\n"
                    f"🛑 حد ضرر: {spike['targets']['stop_loss']}\n"
                    f"〰️〰️〰️〰️〰️〰️〰️〰️\n"
                )

                if len(message + spike_message) > 3800:
                    self.bot.send_message(chat_id, message)
                    message = spike_message
                else:
                    message += spike_message

        if message:
            self.bot.send_message(chat_id, message)

            """Calculate Rolling Standard Deviation"""
            #return np.array([np.std(data[max(0, i - window):i]) for i in range(1, len(data) + 1)])

#divergence
    def analyze_divergence(self, chat_id, timeframe=None):
        self.clean_cache()
        """تحلیل واگرایی‌ها با سنتیمنت و اندیکاتورهای پیشرفته"""
        settings = self.db.get_user_settings(chat_id)
        timeframe = timeframe or settings['timeframe']
        
        user_coins = self.db.get_user_coins(chat_id)
        if not user_coins:
            self.bot.send_message(chat_id, "⚠️ لیست ارزها خالی است")
            return

        self.bot.send_message(
            chat_id, 
            f"🔍 تحلیل واگرایی در تایم‌فریم {timeframe}"
        )

        grouped_results = {}

        for coin in user_coins:
            symbol = coin['symbol']
            group_name = coin['group_name']
            
            # دریافت داده‌ها با کش
            kline_data = self.get_cached_kline_data(symbol, timeframe)
            if not kline_data:
                continue
                
            # دریافت سنتیمنت بازار
            market_sentiment = self.get_market_sentiment(symbol)
            
            divergences = self.find_divergence(kline_data, market_sentiment)
            
            if divergences:
                if group_name not in grouped_results:
                    grouped_results[group_name] = []
                for div in divergences:
                    div['symbol'] = symbol
                grouped_results[group_name].extend(divergences)

        if grouped_results:
            self._send_enhanced_divergence_results(chat_id, grouped_results, timeframe)
        else:
            self.bot.send_message(
                chat_id, 
                "❌ هیچ واگرایی در ارزهای انتخابی یافت نشد"
            )
        # برگشت به منوی اصلی
        message = types.Message(
            message_id=None,
            from_user=None,
            date=None,
            chat=types.Chat(id=chat_id, type=None),
            content_type=None,
            options={},
            json_string=None
        )
        self.bot.message_handlers[0]['function'](message)

    def find_divergence(self, kline_data, sentiment=None):
        """Enhanced divergence analysis with multiple confirmation points"""
        divergences = []
        
        # تبدیل داده‌ها به آرایه numpy
        np_data = np.array([[float(x) for x in candle] for candle in kline_data])
        closes = np_data[:, 4]
        highs = np_data[:, 2]
        lows = np_data[:, 3]
        volumes = np_data[:, 5]
        
        # محاسبه اندیکاتورها
        rsi = np.array(self.calculate_rsi(closes, 14))
        macd, signal, hist = self.calculate_macd(closes)
        macd = np.array(macd)
        stoch_k, stoch_d = self.calculate_stochastic(highs, lows, closes, 14, 3)
        stoch_k = np.array(stoch_k)
        
        # یافتن کوچکترین طول آرایه
        min_length = min(len(rsi), len(macd), len(stoch_k))
        
        # برش آرایه‌ها به طول یکسان
        rsi = rsi[-min_length:]
        macd = macd[-min_length:]
        stoch_k = stoch_k[-min_length:]
        
        # پنجره تحلیل
        window = 15
        
        for i in range(window, min_length-1):
            # Bullish divergence conditions
            if (self.is_bullish_divergence(
                lows[i-window:i+1],
                rsi[i-window:i+1],
                macd[i-window:i+1],
                stoch_k[i-window:i+1]
            )):
                div_data = self.calculate_divergence_metrics(
                    'مثبت 📈',
                    kline_data[i],
                    closes[i],
                    rsi[i],
                    volumes[i],
                    sentiment,
                    macd[i],
                    stoch_k[i]
                )
                divergences.append(div_data)
                
            # Bearish divergence conditions    
            elif (self.is_bearish_divergence(
                highs[i-window:i+1],
                rsi[i-window:i+1], 
                macd[i-window:i+1],
                stoch_k[i-window:i+1]
            )):
                div_data = self.calculate_divergence_metrics(
                    'منفی 📉',
                    kline_data[i],
                    closes[i],
                    rsi[i],
                    volumes[i],
                    sentiment,
                    macd[i],
                    stoch_k[i]
                )
                divergences.append(div_data)
        
        return sorted(divergences, key=lambda x: x['strength'], reverse=True)

    def is_bullish_divergence(self, prices, rsi_values, macd_values, stoch_values):
        """Enhanced bullish divergence detection"""
        try:
            # Find multiple low points
            price_lows = self.find_significant_lows(prices, 3)
            rsi_lows = self.find_significant_lows(rsi_values, 3)
            macd_lows = self.find_significant_lows(macd_values, 3)
            stoch_lows = self.find_significant_lows(stoch_values, 3)
            
            # More lenient conditions
            price_trend = price_lows[-1] <= price_lows[0] * 0.995  # 0.5% tolerance
            indicator_trend = (
                rsi_lows[-1] >= rsi_lows[0] * 1.02 or  # 2% minimum divergence
                macd_lows[-1] >= macd_lows[0] * 1.02 or
                stoch_lows[-1] >= stoch_lows[0] * 1.02
            )
            
            return price_trend and indicator_trend
        except:
            return False

    def is_bearish_divergence(self, prices, rsi_values, macd_values, stoch_values):
        """Enhanced bearish divergence detection"""
        try:
            # Find multiple high points
            price_highs = self.find_significant_highs(prices, 3)
            rsi_highs = self.find_significant_highs(rsi_values, 3)
            macd_highs = self.find_significant_highs(macd_values, 3)
            stoch_highs = self.find_significant_highs(stoch_values, 3)
            
            # More lenient conditions
            price_trend = price_highs[-1] >= price_highs[0] * 1.005  # 0.5% tolerance
            indicator_trend = (
                rsi_highs[-1] <= rsi_highs[0] * 0.98 or  # 2% minimum divergence
                macd_highs[-1] <= macd_highs[0] * 0.98 or
                stoch_highs[-1] <= stoch_highs[0] * 0.98
            )
            
            return price_trend and indicator_trend
        except:
            return False

    def find_significant_highs(self, data, num_points=3):
        """Find significant high points in the data"""
        window = len(data) // num_points
        highs = []
        
        for i in range(num_points):
            start = i * window
            end = (i + 1) * window
            segment = data[start:end]
            highs.append(max(segment))
        
        return highs

    def calculate_divergence_strength(self, div_type, price, rsi, volume, sentiment, macd_diff, band_level):
        """محاسبه قدرت سیگنال واگرایی"""
        strength = 0
        
        # محاسبه امتیاز بر اساس RSI
        if div_type == 'مثبت 📈':
            if rsi < 30: strength += 30
            elif rsi < 40: strength += 20
        else:  # واگرایی منفی
            if rsi > 70: strength += 30
            elif rsi > 60: strength += 20
        
        # محاسبه امتیاز بر اساس حجم معاملات
        # حجم به صورت یک عدد منفرد دریافت می‌شود
        if volume > 0:  # اطمینان از مثبت بودن حجم
            strength += 15
            
        # محاسبه امتیاز بر اساس MACD
        if abs(macd_diff) > 0.5:
            strength += 15
        elif abs(macd_diff) > 0.2:
            strength += 10
            
        # محاسبه امتیاز بر اساس سنتیمنت
        if sentiment and 'total_score' in sentiment:
            if div_type == 'مثبت 📈' and sentiment['total_score'] > 60:
                strength += 20
            elif div_type == 'منفی 📉' and sentiment['total_score'] < 40:
                strength += 20
        
        # محاسبه امتیاز بر اساس باند بولینگر
        if band_level:
            if div_type == 'مثبت 📈' and price < band_level:
                strength += 20
            elif div_type == 'منفی 📉' and price > band_level:
                strength += 20
                
        # اطمینان از محدوده 0-100
        return min(max(strength, 0), 100)

    def calculate_divergence_targets(self, div_type, price, sentiment):
        """محاسبه اهداف قیمتی برای واگرایی"""
        
        # ضرایب محاسبه اهداف بر اساس نوع واگرایی و سنتیمنت
        if div_type == 'مثبت 📈':
            multiplier = 1.0
            if sentiment and sentiment.get('total_score', 50) > 60:
                multiplier = 1.2
            
            target1 = price * (1 + 0.02 * multiplier)  # هدف اول: 2%
            target2 = price * (1 + 0.035 * multiplier)  # هدف دوم: 3.5%
            target3 = price * (1 + 0.05 * multiplier)  # هدف سوم: 5%
            stop_loss = price * 0.985  # حد ضرر: 1.5%
            
        else:  # واگرایی منفی
            multiplier = 1.0
            if sentiment and sentiment.get('total_score', 50) < 40:
                multiplier = 1.2
                
            target1 = price * (1 - 0.02 * multiplier)
            target2 = price * (1 - 0.035 * multiplier)
            target3 = price * (1 - 0.05 * multiplier)
            stop_loss = price * 1.015
        
        return {
            'target1': round(target1, 8),
            'target2': round(target2, 8),
            'target3': round(target3, 8),
            'stop_loss': round(stop_loss, 8)
        }

    def calculate_divergence_metrics(self, div_type, candle, price, rsi, volume, sentiment, macd_diff, band_level):
        """محاسبه متریک‌های پیشرفته واگرایی"""
        
        # محاسبه قدرت واگرایی
        strength = self.calculate_divergence_strength(
            div_type,
            price,
            rsi,
            volume,
            sentiment,
            macd_diff,
            band_level
        )
        
        # محاسبه اهداف قیمتی
        targets = self.calculate_divergence_targets(
            div_type,
            price,
            sentiment
        )
        
        # محاسبه احتمال موفقیت
        probability = self.calculate_divergence_probability(
            div_type,
            rsi,
            volume,
            sentiment
        )
        
        # محاسبه سطح ریسک
        risk_level = self.calculate_divergence_risk(
            div_type,
            rsi,
            volume,
            sentiment
        )
        
        return {
            'type': div_type,
            'time': datetime.fromtimestamp(candle[0] / 1000).strftime('%Y-%m-%d %H:%M'),
            'price': float(price),
            'rsi': float(rsi),
            'strength': strength,
            'targets': targets,
            'stop_loss': targets['stop_loss'],
            'probability': probability,
            'risk_level': risk_level,
            'sentiment': sentiment
        }

    def _send_enhanced_divergence_results(self, chat_id, grouped_results, timeframe):
        """ارسال نتایج پیشرفته تحلیل واگرایی"""
        message = f"📊 نتایج تحلیل واگرایی در تایم‌فریم {timeframe}:\n\n"
        
        for group_name, divergences in grouped_results.items():
            message += f"📌 گروه {group_name}:\n"
            
            for div in divergences[:3]:  # نمایش 3 واگرایی برتر هر گروه
                strength_emoji = self._get_strength_emoji(div['strength'])
                probability_emoji = self._get_probability_emoji(div['probability'])
                sentiment_status = self._get_sentiment_status(div['sentiment']['total_score'])
                
                div_message = (
                    f"🔸 {div['symbol']}\n"
                    f"{strength_emoji} واگرایی {div['type']}\n"
                    f"⏰ زمان: {div['time']}\n"
                    f"💪 قدرت سیگنال: {div['strength']}/100\n"
                    f"📊 احتمال موفقیت: {div['probability']}% {probability_emoji}\n"
                    f"🌊 سنتیمنت بازار: {sentiment_status}\n"
                    f"⚠️ سطح ریسک: {self._format_risk_level(div['risk_level'])}\n\n"
                    f"🎯 اهداف قیمتی:\n"
                    f"   ①: {div['targets']['target1']}\n"
                    f"   ②: {div['targets']['target2']}\n"
                    f"   ③: {div['targets']['target3']}\n"
                    f"🛑 حد ضرر: {div['targets']['stop_loss']}\n"
                    f"〰️〰️〰️〰️〰️〰️〰️〰️\n"
                )
                
                if len(message + div_message) > 3800:
                    self.bot.send_message(chat_id, message)
                    message = div_message
                else:
                    message += div_message
        
        if message:
            self.bot.send_message(chat_id, message)

    def find_significant_lows(self, data, num_points=3):
        """Find significant low points in the data"""
        window = len(data) // num_points
        lows = []
        
        for i in range(num_points):
            start = i * window
            end = (i + 1) * window
            segment = data[start:end]
            lows.append(min(segment))
        
        return lows

    def calculate_stochastic(self, high, low, close, k_period=14, d_period=3):
        """Calculate Stochastic Oscillator"""
        # Convert inputs to numpy arrays
        high = np.array(high)
        low = np.array(low)
        close = np.array(close)
        
        # Calculate %K
        lowest_low = pd.Series(low).rolling(window=k_period).min()
        highest_high = pd.Series(high).rolling(window=k_period).max()
        
        # Handle division by zero
        denominator = highest_high - lowest_low
        denominator[denominator == 0] = 1  # Avoid division by zero
        
        k = 100 * ((close - lowest_low) / denominator)
        
        # Calculate %D
        d = pd.Series(k).rolling(window=d_period).mean()
        
        return k, d

    def calculate_divergence_probability(self, div_type, rsi, volume, sentiment):
        """محاسبه احتمال موفقیت واگرایی"""
        probability = 50  # احتمال پایه
        
        # تحلیل RSI
        if div_type == 'مثبت 📈':
            if rsi < 30: probability += 15
            elif rsi < 40: probability += 10
        else:  # واگرایی منفی
            if rsi > 70: probability += 15
            elif rsi > 60: probability += 10
        
        # تحلیل حجم معاملات
        if volume > 0:
            probability += 10
        
        # تحلیل سنتیمنت
        if sentiment and 'total_score' in sentiment:
            if div_type == 'مثبت 📈':
                if sentiment['total_score'] > 70: probability += 15
                elif sentiment['total_score'] > 60: probability += 10
            else:
                if sentiment['total_score'] < 30: probability += 15
                elif sentiment['total_score'] < 40: probability += 10
        
        # محدود کردن احتمال بین 0 تا 100
        return min(max(probability, 0), 100)

    def calculate_divergence_risk(self, div_type, rsi, volume, sentiment):
        """محاسبه سطح ریسک واگرایی"""
        risk = 50  # ریسک پایه
        
        # تحلیل RSI
        if div_type == 'مثبت 📈':
            if rsi < 20: risk -= 15
            elif rsi < 30: risk -= 10
        else:
            if rsi > 80: risk -= 15
            elif rsi > 70: risk -= 10
        
        # تحلیل سنتیمنت
        if sentiment and 'total_score' in sentiment:
            sentiment_score = sentiment['total_score']
            if div_type == 'مثبت 📈':
                if sentiment_score > 70: risk -= 15
                elif sentiment_score > 60: risk -= 10
            else:
                if sentiment_score < 30: risk -= 15
                elif sentiment_score < 40: risk -= 10
        
        # محدود کردن ریسک بین 0 تا 100
        return min(max(risk, 0), 100)

    def _get_probability_emoji(self, probability):
        """Return emoji based on probability"""
        if probability >= 75:
            return "✅✅✅"
        elif probability >= 50:
            return "✅✅"
        else:
            return "✅"

    def _get_sentiment_status(self, sentiment_score):
        """Return sentiment status text"""
        if sentiment_score >= 70:
            return "بسیار مثبت 🟢"
        elif sentiment_score >= 55:
            return "مثبت 🟢"
        elif sentiment_score >= 45:
            return "خنثی ⚪"
        elif sentiment_score >= 30:
            return "منفی 🔴"
        else:
            return "بسیار منفی 🔴"

    def _format_risk_level(self, risk):
        """فرمت‌بندی سطح ریسک با تبدیل به عدد"""
        try:
            risk_value = float(risk)
            if risk_value <= 30:
                return f"کم 🟢 ({risk_value}%)"
            elif risk_value <= 60:
                return f"متوسط 🟡 ({risk_value}%)"
            else:
                return f"بالا 🔴 ({risk_value}%)"
        except:
            return "نامشخص ⚪"


    def find_last_two_lows(self, data):
        """Find last two significant low points"""
        window = min(20, len(data) // 2)
        lows = []
        
        for i in range(len(data)-window, len(data)):
            if i > 0 and i < len(data)-1:
                if data[i] < data[i-1] and data[i] < data[i+1]:
                    lows.append(data[i])
                    
        if len(lows) >= 2:
            return lows[-2], lows[-1]
        raise ValueError("Not enough low points found")



#triangle

    def analyze_triangle(self, chat_id, timeframe):
        self.clean_cache()
        """تحلیل پیشرفته الگوهای مثلثی با محاسبات دقیق و تاییدات چندگانه"""
        
        user_coins = self.db.get_user_coins(chat_id)
        if not user_coins:
            self.bot.send_message(
                chat_id,
                "⚠️ لیست ارزها خالی است. لطفا ابتدا ارزهای مورد نظر را اضافه کنید."
            )
            return

        self.bot.send_message(chat_id, "🔍 در حال تحلیل پیشرفته الگوهای مثلث...")
        
        grouped_results = {}
        
        for coin in user_coins:
            symbol = coin['symbol']
            group_name = coin['group_name']
            
            # دریافت داده‌ها با کش
            kline_data = self.get_cached_kline_data(symbol, timeframe)
            if not kline_data:
                continue
                
            # دریافت سنتیمنت بازار
            market_sentiment = self.get_market_sentiment(symbol)
            
            triangles = self.find_triangle_patterns(kline_data, market_sentiment)
            
            if triangles:
                if group_name not in grouped_results:
                    grouped_results[group_name] = []
                for triangle in triangles:
                    triangle['symbol'] = symbol
                grouped_results[group_name].extend(triangles)

        if grouped_results:
            self._send_enhanced_triangle_results(chat_id, grouped_results, timeframe)
        else:
            self.bot.send_message(
                chat_id, 
                "❌ هیچ الگوی مثلثی معتبر در ارزهای انتخابی یافت نشد"
            )
        # برگشت به منوی اصلی
        message = types.Message(
            message_id=None,
            from_user=None,
            date=None,
            chat=types.Chat(id=chat_id, type=None),
            content_type=None,
            options={},
            json_string=None
        )
        self.bot.message_handlers[0]['function'](message)
    def find_triangle_patterns(self, data, sentiment=None):
        """تشخیص پیشرفته الگوهای مثلثی با تاییدات تکنیکال"""
        triangles = []
        
        # تبدیل داده‌ها به آرایه numpy
        np_data = np.array([[float(x) for x in candle] for candle in data])
        highs = np_data[:, 2]
        lows = np_data[:, 3]
        closes = np_data[:, 4]
        volumes = np_data[:, 5]
        
        # محاسبه اندیکاتورها
        rsi = self.calculate_rsi(closes, 14)
        macd, signal, hist = self.calculate_macd(closes)
        bb_upper, bb_middle, bb_lower = self.calculate_bollinger_bands(closes, 20)
        
        # همگام‌سازی طول آرایه‌ها
        min_length = min(len(rsi), len(macd), len(signal), len(bb_upper), len(bb_lower))
        
        # پنجره‌های تحلیل مختلف
        windows = [20, 30, 40]
        
        for window in windows:
            if len(data) < window + 1 or window >= min_length:
                continue
                
            for i in range(window, min_length - 1):
                window_highs = highs[i - window:i]
                window_lows = lows[i - window:i]
                
                # محاسبه خطوط روند
                high_slope, high_intercept = self.calculate_trend_line(window_highs)
                low_slope, low_intercept = self.calculate_trend_line(window_lows)
                
                # محاسبه نقطه همگرایی
                try:
                    convergence_point = self.calculate_convergence_point(
                        high_slope, high_intercept, 
                        low_slope, low_intercept
                    )
                except:
                    continue
                    
                current_price = closes[i]
                current_volume = volumes[i]
                avg_volume = np.mean(volumes[i - window:i])
                
                # محاسبه معیارهای اعتبارسنجی
                price_range = abs(window_highs[-1] - window_lows[-1])
                distance_to_convergence = abs(convergence_point - current_price) / current_price * 100
                
                # شرایط تایید الگو
                if self.validate_triangle_pattern(
                    distance_to_convergence,
                    current_volume,
                    avg_volume,
                    rsi[i] if i < len(rsi) else rsi[-1],
                    macd[i] if i < len(macd) else macd[-1],
                    signal[i] if i < len(signal) else signal[-1],
                    current_price,
                    bb_upper[i] if i < len(bb_upper) else bb_upper[-1],
                    bb_lower[i] if i < len(bb_lower) else bb_lower[-1]
                ):
                    triangle_type = self.determine_triangle_type(
                        high_slope, 
                        low_slope,
                        sentiment
                    )
                    
                    targets = self.calculate_triangle_targets(
                        triangle_type,
                        current_price,
                        price_range,
                        sentiment
                    )
                    
                    strength = self.calculate_triangle_strength(
                        triangle_type,
                        distance_to_convergence,
                        current_volume / avg_volume,
                        rsi[i] if i < len(rsi) else rsi[-1],
                        macd[i] - signal[i] if i < len(macd) else macd[-1] - signal[-1],
                        sentiment
                    )
                    
                    triangle_data = {
                        'time': datetime.fromtimestamp(data[i][0] / 1000).strftime('%Y-%m-%d %H:%M'),
                        'type': triangle_type,
                        'upper_price': float(window_highs[-1]),
                        'lower_price': float(window_lows[-1]),
                        'convergence_point': float(convergence_point),
                        'targets': targets,
                        'strength': strength,
                        'volume_ratio': round(current_volume / avg_volume, 2),
                        'completion': round((1 - distance_to_convergence / 5) * 100, 1)
                    }
                    
                    triangles.append(triangle_data)
        
        return sorted(triangles, key=lambda x: x['strength'], reverse=True)

    def validate_triangle_pattern(self, distance, current_vol, avg_vol, rsi, macd, signal, price, bb_upper, bb_lower):
        """اعتبارسنجی الگوی مثلث با معیارهای چندگانه"""
        return (
            distance <= 7 and  # فاصله مناسب تا نقطه همگرایی
            current_vol > avg_vol * 1.2 and  # تایید حجم
            (rsi < 30 or rsi > 70) and  # تایید RSI
            abs(macd - signal) > 0 and  # تایید MACD
            (price <= bb_lower * 1.02 or price >= bb_upper * 0.98)  # تایید باندهای بولینگر
        )

    def calculate_triangle_targets(self, pattern_type, price, range, sentiment):
        """محاسبه اهداف قیمتی براساس نوع مثلث و سنتیمنت"""
        multiplier = 1.0
        if sentiment and 'total_score' in sentiment:
            if pattern_type in ["مثلث صعودی 📈", "مثلث همگرا 📐"] and sentiment['total_score'] > 60:
                multiplier = 1.2
            elif pattern_type == "مثلث نزولی 📉" and sentiment['total_score'] < 40:
                multiplier = 1.2
        
        if pattern_type in ["مثلث صعودی 📈", "مثلث همگرا 📐"]:
            target1 = price * (1 + 0.02 * multiplier)
            target2 = price * (1 + 0.035 * multiplier)
            target3 = price * (1 + 0.05 * multiplier)
            stop_loss = price * 0.985
        else:
            target1 = price * (1 - 0.02 * multiplier)
            target2 = price * (1 - 0.035 * multiplier)
            target3 = price * (1 - 0.05 * multiplier)
            stop_loss = price * 1.015
        
        return {
            'target1': round(target1, 8),
            'target2': round(target2, 8),
            'target3': round(target3, 8),
            'stop_loss': round(stop_loss, 8)
        }

    def calculate_triangle_strength(self, pattern_type, distance, volume_ratio, rsi, macd_diff, sentiment):
        """محاسبه قدرت سیگنال مثلث"""
        strength = 50  # امتیاز پایه
        
        # امتیاز براساس فاصله تا نقطه همگرایی
        strength += (5 - min(distance, 5)) * 5
        
        # امتیاز براساس حجم معاملات
        if volume_ratio > 2: strength += 15
        elif volume_ratio > 1.5: strength += 10
        
        # امتیاز براساس RSI
        if pattern_type in ["مثلث صعودی 📈", "مثلث همگرا 📐"]:
            if rsi < 30: strength += 15
            elif rsi < 40: strength += 10
        else:
            if rsi > 70: strength += 15
            elif rsi > 60: strength += 10
        
        # امتیاز براساس MACD
        if abs(macd_diff) > 0: strength += 10
        
        # امتیاز براساس سنتیمنت
        if sentiment and 'total_score' in sentiment:
            if pattern_type in ["مثلث صعودی 📈", "مثلث همگرا 📐"] and sentiment['total_score'] > 60:
                strength += 15
            elif pattern_type == "مثلث نزولی 📉" and sentiment['total_score'] < 40:
                strength += 15
        
        return min(max(strength, 0), 100)

    def _send_enhanced_triangle_results(self, chat_id, grouped_results, timeframe):
        """ارسال نتایج پیشرفته تحلیل مثلث"""
        message = f"📊 نتایج تحلیل الگوهای مثلث در تایم‌فریم {timeframe}:\n\n"
        
        for group_name, triangles in grouped_results.items():
            message += f"📌 گروه {group_name}:\n"
            
            for triangle in triangles[:3]:  # نمایش 3 الگوی برتر هر گروه
                strength_emoji = self._get_strength_emoji(triangle['strength'])
                
                pattern_message = (
                    f"🔸 {triangle['symbol']}\n"
                    f"📐 نوع الگو: {triangle['type']}\n"
                    f"⏰ زمان: {triangle['time']}\n"
                    f"💪 قدرت سیگنال: {triangle['strength']}/100 {strength_emoji}\n"
                    f"📊 تکمیل الگو: {triangle['completion']}%\n"
                    f"📈 نسبت حجم: {triangle['volume_ratio']}x\n\n"
                    f"🎯 اهداف قیمتی:\n"
                    f"   ①: {triangle['targets']['target1']}\n"
                    f"   ②: {triangle['targets']['target2']}\n"
                    f"   ③: {triangle['targets']['target3']}\n"
                    f"🛑 حد ضرر: {triangle['targets']['stop_loss']}\n"
                    f"〰️〰️〰️〰️〰️〰️〰️〰️\n"
                )
                
                if len(message + pattern_message) > 3800:
                    self.bot.send_message(chat_id, message)
                    message = pattern_message
                else:
                    message += pattern_message
        
        if message:
            self.bot.send_message(chat_id, message)

    def calculate_trend_line(self, prices):
        """محاسبه خط روند با رگرسیون خطی پیشرفته"""
        x = np.arange(len(prices))
        y = prices
        
        # حذف نویز با میانگین متحرک
        y_smooth = np.convolve(y, np.ones(5)/5, mode='valid')
        x_smooth = x[2:-2]
        
        # محاسبه رگرسیون
        coeffs = np.polyfit(x_smooth, y_smooth, 1)
        return coeffs[0], coeffs[1]

    def calculate_convergence_point(self, high_slope, high_intercept, low_slope, low_intercept):
        """محاسبه نقطه همگرایی با اعتبارسنجی"""
        if abs(high_slope - low_slope) < 1e-6:
            raise ValueError("خطوط موازی هستند")
            
        x = (low_intercept - high_intercept) / (high_slope - low_slope)
        y = high_slope * x + high_intercept
        
        if x < 0 or y < 0:
            raise ValueError("نقطه همگرایی نامعتبر")
            
        return y

    def determine_triangle_type(self, high_slope, low_slope, sentiment=None):
        """تعیین نوع مثلث با توجه به شیب خطوط و سنتیمنت بازار"""
        
        # محاسبه شیب‌های نرمال شده
        high_slope_norm = abs(high_slope)
        low_slope_norm = abs(low_slope)
        
        # تعیین نوع مثلث براساس شیب خطوط
        if high_slope < 0 and low_slope > 0:
            if high_slope_norm > low_slope_norm * 1.5:
                triangle_type = "مثلث نزولی 📉"
            elif low_slope_norm > high_slope_norm * 1.5:
                triangle_type = "مثلث صعودی 📈"
            else:
                triangle_type = "مثلث همگرا 📐"
        elif high_slope < 0 and low_slope < 0:
            triangle_type = "مثلث نزولی 📉"
        elif high_slope > 0 and low_slope > 0:
            triangle_type = "مثلث صعودی 📈"
        else:
            triangle_type = "مثلث همگرا 📐"
        
        # تایید با سنتیمنت بازار
        if sentiment and 'total_score' in sentiment:
            if triangle_type == "مثلث صعودی 📈" and sentiment['total_score'] > 60:
                triangle_type = "مثلث صعودی قوی 📈💪"
            elif triangle_type == "مثلث نزولی 📉" and sentiment['total_score'] < 40:
                triangle_type = "مثلث نزولی قوی 📉💪"
        
        return triangle_type


#double

    def analyze_double(self, chat_id, timeframe):
        """تحلیل پیشرفته الگوهای دوقلو"""
        self.clean_cache()
        
        user_coins = self.db.get_user_coins(chat_id)
        if not user_coins:
            self.bot.send_message(
                chat_id,
                "⚠️ لیست ارزها خالی است. لطفا ابتدا ارزهای مورد نظر را اضافه کنید."
            )
            return

        self.bot.send_message(chat_id, "🔍 در حال تحلیل پیشرفته الگوهای دوقلو...")
        
        grouped_results = {}
        
        for coin in user_coins:
            symbol = coin['symbol']
            group_name = coin['group_name']
            
            # دریافت داده‌ها با کش
            kline_data = self.get_cached_kline_data(symbol, timeframe)
            if not kline_data:
                continue
                
            # دریافت سنتیمنت بازار
            market_sentiment = self.get_market_sentiment(symbol)
            
            patterns = self.find_double_pattern(kline_data)
            
            if patterns:
                if group_name not in grouped_results:
                    grouped_results[group_name] = []
                for pattern in patterns:
                    pattern['symbol'] = symbol
                grouped_results[group_name].extend(patterns)

        if grouped_results:
            self._send_enhanced_double_results(chat_id, grouped_results, timeframe)
        else:
            self.bot.send_message(
                chat_id, 
                "❌ هیچ الگوی دوقلوی معتبر در ارزهای انتخابی یافت نشد"
            )
        # برگشت به منوی اصلی
        message = types.Message(
            message_id=None,
            from_user=None,
            date=None,
            chat=types.Chat(id=chat_id, type=None),
            content_type=None,
            options={},
            json_string=None
        )
        self.bot.message_handlers[0]['function'](message)

    def _send_enhanced_double_results(self, chat_id, grouped_results, timeframe):
        """ارسال نتایج پیشرفته تحلیل دوقلو"""
        message = f"📊 نتایج تحلیل الگوهای دوقلو در تایم‌فریم {timeframe}:\n\n"
        
        for group_name, patterns in grouped_results.items():
            message += f"📌 گروه {group_name}:\n"
            
            for pattern in patterns[:3]:  # نمایش 3 الگوی برتر هر گروه
                strength_emoji = self._get_strength_emoji(pattern['strength'])
                
                pattern_message = (
                    f"🔸 {pattern['symbol']}\n"
                    f"📐 نوع الگو: {pattern['type']}\n"
                    f"⏰ زمان: {pattern['time']}\n"
                    f"💪 قدرت سیگنال: {pattern['strength']}/100 {strength_emoji}\n"
                    f"⚠️ سطح ریسک: {self._format_risk_level(pattern['risk_level'])}\n\n"
                    f"🎯 اهداف قیمتی:\n"
                    f"   ①: {pattern['targets']['target1']}\n"
                    f"   ②: {pattern['targets']['target2']}\n"
                    f"   ③: {pattern['targets']['target3']}\n"
                    f"🛑 حد ضرر: {pattern['targets']['stop_loss']}\n"
                    f"〰️〰️〰️〰️〰️〰️〰️〰️\n"
                )
                
                if len(message + pattern_message) > 3800:
                    self.bot.send_message(chat_id, message)
                    message = pattern_message
                else:
                    message += pattern_message
        
        if message:
            self.bot.send_message(chat_id, message)

    def find_double_pattern(self, data):
        """تشخیص پیشرفته الگوهای دوقلو با تاییدات تکنیکال"""
        patterns = []
        
        # تبدیل داده‌ها به آرایه numpy
        np_data = np.array([[float(x) for x in candle] for candle in data])
        highs = np_data[:, 2]
        lows = np_data[:, 3]
        closes = np_data[:, 4]
        volumes = np_data[:, 5]
        
        # محاسبه اندیکاتورها
        rsi = self.calculate_rsi(closes, 14)
        macd, signal, hist = self.calculate_macd(closes)
        bb_upper, bb_middle, bb_lower = self.calculate_bollinger_bands(closes, 20)
        
        # محاسبه میانگین حجم
        volume_sma = self.calculate_sma(volumes, 20)
        
        # پنجره‌های تحلیل
        windows = [20, 30]
        
        for window in windows:
            if len(data) < window + 1:
                continue
                
            for i in range(window, len(data) - 1):
                window_highs = highs[i - window:i]
                window_lows = lows[i - window:i]
                
                # تشخیص دوقلوی صعودی
                if self.is_double_bottom(window_lows, window_highs, volumes[i-window:i]):
                    pattern = {
                        'time': datetime.fromtimestamp(data[i][0] / 1000).strftime('%Y-%m-%d %H:%M'),
                        'type': 'دوقلوی صعودی 📈',
                        'price': closes[i],
                        'confirmation': np.max(window_highs),
                        'strength': self.calculate_pattern_strength(
                            'bullish',
                            closes[i],
                            volumes[i],
                            volume_sma[i] if i < len(volume_sma) else volume_sma[-1],
                            rsi[i] if i < len(rsi) else rsi[-1],
                            macd[i] if i < len(macd) else macd[-1],
                            signal[i] if i < len(signal) else signal[-1]
                        ),
                        'targets': self.calculate_double_targets(closes[i], True),
                        'risk_level': self.calculate_pattern_risk(
                            closes[i],
                            bb_upper[i] if i < len(bb_upper) else bb_upper[-1],
                            bb_lower[i] if i < len(bb_lower) else bb_lower[-1],
                            rsi[i] if i < len(rsi) else rsi[-1]
                        )
                    }
                    patterns.append(pattern)
                
                # تشخیص دوقلوی نزولی
                if self.is_double_top(window_highs, window_lows, volumes[i-window:i]):
                    pattern = {
                        'time': datetime.fromtimestamp(data[i][0] / 1000).strftime('%Y-%m-%d %H:%M'),
                        'type': 'دوقلوی نزولی 📉',
                        'price': closes[i],
                        'confirmation': np.min(window_lows),
                        'strength': self.calculate_pattern_strength(
                            'bearish',
                            closes[i],
                            volumes[i],
                            volume_sma[i] if i < len(volume_sma) else volume_sma[-1],
                            rsi[i] if i < len(rsi) else rsi[-1],
                            macd[i] if i < len(macd) else macd[-1],
                            signal[i] if i < len(signal) else signal[-1]
                        ),
                        'targets': self.calculate_double_targets(closes[i], False),
                        'risk_level': self.calculate_pattern_risk(
                            closes[i],
                            bb_upper[i] if i < len(bb_upper) else bb_upper[-1],
                            bb_lower[i] if i < len(bb_lower) else bb_lower[-1],
                            rsi[i] if i < len(rsi) else rsi[-1]
                        )
                    }
                    patterns.append(pattern)
        
        return sorted(patterns, key=lambda x: x['strength'], reverse=True)

    def is_double_bottom(self, lows, highs, volumes):
        """تشخیص الگوی دوقلوی صعودی"""
        min_indices = signal.find_peaks(-lows)[0]
        if len(min_indices) < 2:
            return False
        
        # بررسی فاصله بین دره‌ها
        price_diff = abs(lows[min_indices[-1]] - lows[min_indices[-2]]) / lows[min_indices[-2]]
        if price_diff > 0.02:  # تفاوت قیمت کمتر از 2%
            return False
        
        # بررسی حجم معاملات
        if volumes[min_indices[-1]] < volumes[min_indices[-2]] * 1.2:
            return False
            
        return True

    def is_double_top(self, highs, lows, volumes):
        """تشخیص الگوی دوقلوی نزولی"""
        max_indices = signal.find_peaks(highs)[0]
        if len(max_indices) < 2:
            return False
        
        # بررسی فاصله بین قله‌ها
        price_diff = abs(highs[max_indices[-1]] - highs[max_indices[-2]]) / highs[max_indices[-2]]
        if price_diff > 0.02:  # تفاوت قیمت کمتر از 2%
            return False
        
        # بررسی حجم معاملات
        if volumes[max_indices[-1]] < volumes[max_indices[-2]] * 1.2:
            return False
            
        return True

    def calculate_double_targets(self, price, is_bullish):
        """محاسبه اهداف قیمتی الگوی دوقلو"""
        if is_bullish:
            target1 = price * 1.02
            target2 = price * 1.035
            target3 = price * 1.05
            stop_loss = price * 0.985
        else:
            target1 = price * 0.98
            target2 = price * 0.965
            target3 = price * 0.95
            stop_loss = price * 1.015
        
        return {
            'target1': round(target1, 8),
            'target2': round(target2, 8),
            'target3': round(target3, 8),
            'stop_loss': round(stop_loss, 8)
        }

    def calculate_pattern_strength(self, pattern_type, price, volume, volume_sma, rsi, macd, signal):
        """محاسبه قدرت الگوی دوقلو"""
        strength = 50  # امتیاز پایه
        
        # تحلیل حجم معاملات
        volume_ratio = volume / volume_sma
        if volume_ratio > 1.5:
            strength += 15
        elif volume_ratio > 1.2:
            strength += 10
            
        # تحلیل RSI
        if pattern_type == 'bullish':
            if rsi < 30:
                strength += 15
            elif rsi < 40:
                strength += 10
        else:  # bearish
            if rsi > 70:
                strength += 15
            elif rsi > 60:
                strength += 10
                
        # تحلیل MACD
        macd_diff = macd - signal
        if pattern_type == 'bullish' and macd_diff > 0:
            strength += 10
        elif pattern_type == 'bearish' and macd_diff < 0:
            strength += 10
            
        # محدود کردن امتیاز نهایی
        strength = min(max(strength, 0), 100)
        
        return round(strength, 1)

    def calculate_pattern_risk(self, price, bb_upper, bb_lower, rsi):
        """محاسبه ریسک الگوی دوقلو با معیارهای تکنیکال"""
        risk = 50  # ریسک پایه
        
        # تحلیل موقعیت قیمت نسبت به باندهای بولینگر
        bb_position = (price - bb_lower) / (bb_upper - bb_lower) * 100
        
        if bb_position > 80:
            risk += 20  # نزدیک به باند بالایی - ریسک بالا
        elif bb_position < 20:
            risk += 15  # نزدیک به باند پایینی - ریسک متوسط
        
        # تحلیل RSI
        if rsi > 70:
            risk += 15  # اشباع خرید
        elif rsi < 30:
            risk += 10  # اشباع فروش
        elif 45 <= rsi <= 55:
            risk -= 10  # محدوده متعادل
        
        # محدود کردن ریسک نهایی
        risk = min(max(risk, 0), 100)
        
        return round(risk, 1)


#harmonic



class UserDatabase:
    def __init__(self):
        self.conn = sqlite3.connect('user_data.db', check_same_thread=False)
        self.create_tables()

    def create_tables(self):
        cursor = self.conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS user_coins (
                user_id INTEGER,
                coin_symbol TEXT,
                added_date TIMESTAMP,
                group_name TEXT DEFAULT 'عمومی',
                PRIMARY KEY (user_id, coin_symbol)
            )
        ''')
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS user_settings (
                user_id INTEGER PRIMARY KEY,
                timeframe TEXT DEFAULT '1h',
                gap_threshold REAL DEFAULT 0.2,
                spike_threshold REAL DEFAULT 1.5,
                notifications BOOLEAN DEFAULT 1
            )
        ''')
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS user_groups (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                group_name TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(user_id, group_name)
            )
        ''')
        # جدول جدید لاگ‌ها
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                level TEXT NOT NULL,
                message TEXT NOT NULL,
                user_id INTEGER,
                action TEXT,
                details TEXT
            )
        ''')
        self.conn.commit()

    def add_user_coin(self, user_id, coin_symbol):
        try:
            cursor = self.conn.cursor()
            cursor.execute('''
                INSERT INTO user_coins (user_id, coin_symbol, added_date)
                VALUES (?, ?, datetime('now'))
            ''', (user_id, coin_symbol))
            self.conn.commit()
            return True
        except sqlite3.IntegrityError:  # اگر ارز قبلاً اضافه شده باشد
            return False

    def get_user_settings(self, user_id):
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT OR IGNORE INTO user_settings (user_id)
            VALUES (?)
        ''', (user_id,))
        self.conn.commit()

        cursor.execute('''
            SELECT timeframe, gap_threshold, spike_threshold, notifications
            FROM user_settings
            WHERE user_id = ?
        ''', (user_id,))

        row = cursor.fetchone()
        return {
            'timeframe': row[0],
            'gap_threshold': row[1],
            'spike_threshold': row[2],
            'notifications': bool(row[3])
        }

    def update_user_settings(self, user_id, timeframe, gap_threshold, spike_threshold, notifications):
        cursor = self.conn.cursor()
        cursor.execute("""
            UPDATE user_settings 
            SET timeframe = ?, 
                gap_threshold = ?, 
                spike_threshold = ?, 
                notifications = ?
            WHERE user_id = ?
        """, (timeframe, gap_threshold, spike_threshold, notifications, user_id))

        # If user doesn't exist, create new settings
        if cursor.rowcount == 0:
            cursor.execute("""
                INSERT INTO user_settings 
                (user_id, timeframe, gap_threshold, spike_threshold, notifications)
                VALUES (?, ?, ?, ?, ?)
            """, (user_id, timeframe, gap_threshold, spike_threshold, notifications))

        self.conn.commit()
        return True

    def reset_user_settings(self, user_id):
        cursor = self.conn.cursor()
        cursor.execute('''
            UPDATE user_settings
            SET timeframe = '1h',
                gap_threshold = 0.2,
                spike_threshold = 1.5,
                notifications = 1
            WHERE user_id = ?
        ''', (user_id,))
        self.conn.commit()

    def update_spike_threshold(self, user_id, value):
        cursor = self.conn.cursor()
        cursor.execute('''
            UPDATE user_settings 
            SET spike_threshold = ? 
            WHERE user_id = ?
        ''', (value, user_id))
        self.conn.commit()

    def get_user_coins(self, user_id):
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT coin_symbol, group_name, added_date
            FROM user_coins
            WHERE user_id = ?
            ORDER BY group_name, added_date
        ''', (user_id,))

        coins = []
        for row in cursor.fetchall():
            coins.append({
                'symbol': row[0],
                'group_name': row[1],
                'added_date': row[2]
            })
        return coins

    def add_group(self, user_id, group_name):
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT OR IGNORE INTO user_groups (user_id, group_name)
            VALUES (?, ?)
        ''', (user_id, group_name))
        self.conn.commit()


def main():
    token = '6688757274:AAE-jz_tz2zQIf-nJ3lDjWp2wPt19MU5FBo'

    while True:
        try:
            analyzer = MarketAnalyzer(token)
            analyzer.run()
        except requests.exceptions.ReadTimeout:
            print("🔄 Timeout occurred, reconnecting...")
            time.sleep(5)  # انتظار 5 ثانیه قبل از اتصال مجدد
            continue
        except requests.exceptions.ProxyError:
            print("🔄 Proxy error, reconnecting...")
            time.sleep(5)
            continue
        except Exception as e:
            print(f"⚠️ Error occurred: {e}")
            time.sleep(5)
            continue


if __name__ == "__main__":
    main()
