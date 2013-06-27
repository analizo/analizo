#!/usr/bin/env python
# coding=utf8

from flask import Flask, render_template
from flask.ext.bootstrap import Bootstrap
from flask.ext.wtf import Form, TextField, HiddenField, ValidationError, Required, RecaptchaField

app = Flask(__name__)
Bootstrap(app)

app.config['BOOTSTRAP_USE_MINIFIED'] = True
app.config['BOOTSTRAP_USE_CDN'] = True
app.config['BOOTSTRAP_FONTAWESOME'] = True
app.config['SECRET_KEY'] = 'devkey'
app.config['RECAPTCHA_PUBLIC_KEY'] = '6Lfol9cSAAAAADAkodaYl9wvQCwBMr3qGR_PPHcw'

@app.route('/')
def index():
    return render_template('home.html')

@app.route('/details')
def details():
    return render_template('details.html')

@app.route('/404')
def error_404():
    return render_template('404.html')


if '__main__' == __name__:
    app.run(debug=True)
