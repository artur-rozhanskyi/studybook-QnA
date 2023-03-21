import 'core-js/stable';
import 'regenerator-runtime/runtime';

import '../src/application.scss';
import '../src/search.scss';

import '@fortawesome/fontawesome-free/js/all';

import Rails from 'rails-ujs';
import Turbolinks from 'turbolinks';
import * as ActiveStorage from 'activestorage';
import 'jquery';
import './answers';
import './cable';
import './comments';
import './questions';
import './search';

Rails.start();
Turbolinks.start();
ActiveStorage.start();
