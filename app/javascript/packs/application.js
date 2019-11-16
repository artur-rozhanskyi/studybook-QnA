import 'core-js/stable'
import 'regenerator-runtime/runtime'

import Rails from 'rails-ujs'
import Turbolinks from 'turbolinks'
import * as ActiveStorage from 'activestorage'
import 'jquery'
window.PrivatePub = require('exports-loader?PrivatePub!private_pub')

Rails.start()
Turbolinks.start()
ActiveStorage.start()

// JavaScript
const webpackContext = require.context('/', true, /\.js$/)
for (const key of webpackContext.keys()) { webpackContext(key) }
