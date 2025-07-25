
# importa l'API de Telegram
from telegram.ext import Application, CommandHandler,ContextTypes
from telegram import Update,Location
from telegram import InputMessageContent 
import datetime
from staticmap import StaticMap, CircleMarker
import os,random


# defineix una funció que saluda i que s'executarà quan el bot rebi el missatge /start
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Inform user about what this bot can do"""
    await update.message.reply_text(
    "👏👏 Felicitats! Tot el món mundial ja pot parlar amb el bot del Campalans!!! 🎉 🎊")
    await update.message.reply_text(
        "Utilitza  /help per veure les comandes disponibles"
    )

    
async def help(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("Soc un bot amb comandes /start, /help , /hora, /encuesta, /photo")

async def hora(update: Update, context: ContextTypes.DEFAULT_TYPE):
    missatge = str(datetime.datetime.now())
    await update.message.reply_text(missatge)

async def poll(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Sends a predefined poll"""
    questions = ["Muy Malo", "Malo", "Bueno", "Muy Bueno"]
    message = await context.bot.send_poll(
        update.effective_chat.id,
        "Que tipo de estudiante eres?",
        questions,
        is_anonymous=False,
        allows_multiple_answers=True,
    )


async def where1(update: Update, context: ContextTypes.DEFAULT_TYPE):
    lat = Location
    lat = await update.message.location.latitude
    lon = await update.message.location.longitude
    print(lat, lon)
    message = await context.bot.send_message(
        chat_id=update.effective_chat.id,
        text='Ets a les coordenades %f %f' % (lat, lon))

async def photo(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
   
    message = await context.bot.send_photo(chat_id=update.effective_chat.id, photo=open('./bicing.png', 'rb')
                    )
    

#Com que la geolocalització Telegram l'ha fet de pagament
# passem les coordenades per parametres
# Ex: /where2 41.681715 2.767685
async def where2(update, context):
    try:
        lat = float(context.args[0])
        lon = float(context.args[1])
        # lat, lon = update.message.location.latitude, update.message.location.longitude
        print(lat, lon)
        fitxer = "%d.png" % random.randint(1000000, 9999999)
        mapa = StaticMap(500, 500)
        mapa.add_marker(CircleMarker((lon, lat), 'blue', 10))
        imatge = mapa.render()
        imatge.save(fitxer)
        message = await context.bot.send_photo(
            chat_id=update.effective_chat.id,
            photo=open(fitxer, 'rb'))
        os.remove(fitxer)
    except Exception as e:
        print(e)
        context.bot.send_message(
            chat_id=update.effective_chat.id,
            text='💣')

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
    print(TOKEN)
    
    application = Application.builder().token(TOKEN).build()
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("help", help))
    application.add_handler(CommandHandler("hora", hora))
    application.add_handler(CommandHandler("photo", photo))
    application.add_handler(CommandHandler("encuesta", poll))
    application.add_handler(CommandHandler("traduir", trad))
    application.add_handler(CommandHandler("suma", suma))
    application.add_handler(CommandHandler("where1", where1))
    application.add_handler(CommandHandler("where2", where2))

    # Run the bot until the user presses Ctrl-C
    application.run_polling()


if __name__ == "__main__":
    main()
