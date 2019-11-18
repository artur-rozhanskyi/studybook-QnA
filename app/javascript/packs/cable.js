import ActionCable from 'actioncable';

window.App = window.App || {};
window.App.cable = ActionCable.createConsumer();
