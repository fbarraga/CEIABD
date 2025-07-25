from flask import Blueprint, render_template, request, flash, redirect, url_for
from flask_login import login_required, current_user
from werkzeug.security import generate_password_hash
from . import db, models

main = Blueprint('main', __name__)

@main.route('/')
def index():
    return render_template('index.html')

@main.route('/profile')
def profile():
    return render_template('profile.html')

@main.route('/user_list')
@login_required
def user_list():
    logged_rol = current_user.rol
    if logged_rol == "Administrador":
        users = db.get_all_users()
    else:
        raise Exception("Operació no permesa per aquest rol", logged_rol)

    return render_template('user_list.html', users=users)

@main.route('/client_list')
@login_required
def client_list():
    logged_rol = current_user.rol
    if logged_rol == "Técnico":
        logged_email = current_user.email
        users = db.get_child_users_by_email(email=logged_email)
    else:
        raise Exception("Operació no permesa per aquest rol", logged_rol)

    return render_template('client_list.html', users=users)

@main.route('/user_create')
@login_required
def user_create():
    return render_template('user_create.html')

@main.route('/user_create', methods=['POST'])
@login_required
def user_create_post():
    email = request.form.get('email')
    nombre = request.form.get('nombre')
    password1 = request.form.get('password1')
    password2 = request.form.get('password2')
    rol = request.form.get('rol')

    user = db.get_user(email)

    if password1 != password2:
        flash(f"Les contrasenyes no coincideixen {password1} {password2}", "error")
        return redirect(url_for('main.user_create'))       

    if user: # if a user is found, we want to redirect back to user_create page so user can try again
        flash('Ja existeix un usuari amb aquest email', "error")
        return redirect(url_for('main.user_create'))

    # create a new user with the form data. Hash the password so the plaintext version isn't saved.
    new_user = models.User(id=None, email=email, nombre=nombre, password=generate_password_hash(password1, method='sha256'), rol=rol)

    # añadimos el usuario a la base de datos
    result = db.insert_user(new_user)
    print("Usuari creat", result.inserted_id, result.acknowledged)

    return redirect(url_for('main.user_list'))

@main.route('/client_create')
@login_required
def client_create():
    return render_template('client_create.html')

@main.route('/client_create', methods=['POST'])
@login_required
def client_create_post():
    email = request.form.get('email')
    nombre = request.form.get('nombre')
    password1 = request.form.get('password1')
    password2 = request.form.get('password2')
    rol = "Cliente"
    parent = current_user.email

    user = db.get_user(email)

    if password1 != password2:
        flash(f"Les contrasenyes no coincideixen  {password1} {password2}", "error")
        return redirect(url_for('main.client_create'))

    if user: # if a user is found, we want to redirect back to user_create page so user can try again
        flash('Ja existeix un usuari amb aquest email', "error")
        return redirect(url_for('main.client_create'))

    # create a new user with the form data. Hash the password so the plaintext version isn't saved.
    new_user = models.User(id=None, email=email, nombre=nombre, password=generate_password_hash(password1, method='sha256'), rol=rol, parent=parent)

    # añadimos el usuario a la base de datos
    result = db.insert_user(new_user)
    print("Usuari cread", result.inserted_id, result.acknowledged)

    return redirect(url_for('main.client_list'))

@main.route('/user_view/<string:id>')
@login_required
def user_view(id):
    print("Recuperando usuario por id:", id)
    user = db.get_user_by_id(id)
    return render_template('user_view.html', user=user)

@main.route('/client_view/<string:id>')
@login_required
def client_view(id):
    print("Recuperando usuario por id:", id)
    user = db.get_user_by_id(id)
    return render_template('client_view.html', user=user)

@main.route('/user_edit/<string:id>')
@login_required
def user_edit(id):
    print("Recuperando usuario por id:", id)
    user = db.get_user_by_id(id)
    return render_template('user_edit.html', user=user)

@main.route('/client_edit/<string:id>')
@login_required
def client_edit(id):
    print("Recuperando cliente por id:", id)
    user = db.get_user_by_id(id)
    return render_template('client_edit.html', user=user)

@main.route('/user_edit', methods=['POST'])
@login_required
def user_edit_post():
    id = request.form.get('id')
    email = request.form.get('email')
    nombre = request.form.get('nombre')
    rol = request.form.get('rol')

    user = db.get_user_by_id(id) 

    if user.id:
        if nombre:
            user.nombre = nombre
        if email:
            user.email = email
        if rol:
            user.rol = rol

        result = db.update_user(user)
        print("Usuario modificado:", result)

        flash('Usuario modificado correctamente', 'info')

    if rol:
        return redirect(url_for('main.user_list'))
    else:
        return redirect(url_for('main.profile'))

@main.route('/client_edit', methods=['POST'])
@login_required
def client_edit_post():
    id = request.form.get('id')
    email = request.form.get('email')
    nombre = request.form.get('nombre')
    rol = request.form.get('rol')

    user = db.get_user_by_id(id) 

    if user.id:
        if nombre:
            user.nombre = nombre
        if email:
            user.email = email

        result = db.update_user(user)
        print("Cliente modificado:", result)

        flash('Cliente modificado correctamente', 'info')

    return redirect(url_for('main.client_list'))

@main.route('/user_remove/<string:id>')
@login_required
def user_remove(id):
    print("Eliminando usuario por id:", id)
    user = db.delete_user(id)
    flash("¡Usuario eliminado con éxito!", 'info')
    return redirect(url_for('main.user_list'))

@main.route('/client_remove/<string:id>')
@login_required
def client_remove(id):
    print("Eliminando cliente por id:", id)
    user = db.delete_user(id)
    flash("Cliente eliminado con éxito!", 'info')
    return redirect(url_for('main.client_list'))