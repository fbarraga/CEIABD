# Llibreries necessaries
# pip install python-telegram-bot

# Afegim funció per tornar l'hora

# importa l'API de Telegram
from telegram.ext import Application, CommandHandler,ContextTypes
from telegram import Update
import datetime

# defineix una funció que saluda i que s'executarà quan el bot rebi el missatge /start
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Informa a l'usuari sobre el cque pot fer el bot"""
    await update.message.reply_text(
    "👏👏 Felicitats! Tot el món mundial ja pot parlar amb el bot!!! 🎉 🎊")
    await update.message.reply_text(
        "Utilitza  /help per veure les comandes disponibles"
    )

    
async def help(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("Soc un bot amb comandes /start, /help , /hora")

async def hora(update: Update, context: ContextTypes.DEFAULT_TYPE):
    missatge = str(datetime.datetime.now())
    await update.message.reply_text(missatge)


def main():
    
    # declara una constant amb el access token que llegeix de token.txt
    TOKEN = open('./token.txt').read().strip()
    
    application = Application.builder().token(TOKEN).build()
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("help", help))
    application.add_handler(CommandHandler("hora", hora))
    
    #  # En execució fins que es pren Ctrl-C
    application.run_polling()


if __name__ == "__main__":
    main()