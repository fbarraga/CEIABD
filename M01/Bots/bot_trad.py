# Llibreries necessaries
# pip install python-telegram-bot
# pip install staticmap
# pip install translate

# importa l'API de Telegram
from telegram.ext import Application, CommandHandler,ContextTypes
from telegram import Update
from translate import Translator
import datetime
import os,random

# defineix una funció que saluda i que s'executarà quan el bot rebi el missatge /start
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Informa a l'usuari sobre el cque pot fer el bot"""
    await update.message.reply_text(
    "👏👏 Felicitats! Tot el món mundial ja pot parlar amb el bot!!! 🎉 🎊")
    await update.message.reply_text(
        "Utilitza  /help per veure les comandes disponibles"
    )

    
async def help(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("Soc un bot amb comandes /start, /help , /hora, /enquesta, /foto, /traduir, /suma")

async def hora(update: Update, context: ContextTypes.DEFAULT_TYPE):
    missatge = str(datetime.datetime.now())
    await update.message.reply_text(missatge)

async def poll(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Envia una enquesta predefinida"""
    questions = ["Molt Dolent", "Dolent", "Bo", "Molt bo"]
    message = await context.bot.send_poll(
        update.effective_chat.id,
         "Quin tipus d'estudiant ets?",
        questions,
        is_anonymous=False,
        allows_multiple_answers=True,
    )

async def trad(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    translator = Translator(from_lang="es",to_lang="en")
    miss_orig = update.message.text[8:]  # esborra el "/traduir " del començament del missatge
    miss_trad = translator.translate(miss_orig)
    message= await context.bot.send_message(
        chat_id=update.effective_chat.id,
        text=miss_trad)

async def photo(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:

    message = await context.bot.send_photo(chat_id=update.effective_chat.id, photo=open('./assets/bicing.png', 'rb')
                    )

async def suma(update, context):
    try:
        x = float(context.args[0])
        y = float(context.args[1])
        s = x + y
        message= await context.bot.send_message(
            chat_id=update.effective_chat.id,
            text=str(s))
    except Exception as e:
        print(e)
        message = await context.bot.send_message(
            chat_id=update.effective_chat.id,
            text='💣')

def main():
    # declara una constant amb el access token que llegeix de token.txt
    TOKEN = open('./token.txt').read().strip()
  
    
    application = Application.builder().token(TOKEN).build()
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("help", help))
    application.add_handler(CommandHandler("hora", hora))
    application.add_handler(CommandHandler("foto", photo))
    application.add_handler(CommandHandler("enquesta", poll))
    application.add_handler(CommandHandler("traduir", trad))
    application.add_handler(CommandHandler("suma", suma))
    
    #  # En execució fins que es pren Ctrl-C
    application.run_polling()


if __name__ == "__main__":
    main()
