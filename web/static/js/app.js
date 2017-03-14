import {Socket} from "phoenix";
import "phoenix_html";
import {ArgonautDatabase} from "./argonaut_database";

const GITHUB_URL_BASE = 'http://git.innova-partners.com/';
const token           = $("meta[name='guardian_token']").prop('content');
window.timeZone       = $("meta[name='time_zone']").prop('content') || "America/New_York";
window.userId         = $("meta[name='user_id']").prop('content');
window.isAdminUser    = $("meta[name='is_admin']").prop('content');
const cellTemplate    = $("#cell-template").html();

const database = new ArgonautDatabase();

var positiveFaces = ['😀', '☺️', '🙂', '😇', '😊', '😛'];
var negativeFaces = ['😥', '😢', '😕', '😒', '☹️', '😞', '😦', '😓', '😫', '🤕', '💩', '😰'];

var getData = function(url, callback){
  return $.ajax({
    beforeSend: function(request) {
      request.setRequestHeader('Authorization', token);
    },
    dataType: "json",
    url: url,
    success: callback
  });
};

var requests = [getData('/api/applications', data => { database.applications = data }),
                getData('/api/environments', data => { database.environments = data }),
                getData('/api/reservations', data => { database.reservations = data })];

function run() {
  _.templateSettings = {
      evaluate:    /\{\{(.+?)\}\}/g,
      interpolate: /\{\{=(.+?)\}\}/g,
      escape:      /\{\{-(.+?)\}\}/g
  };

  $.when(...requests).then(() => {
    render(database);
    connect(database);
  });
}

function render(database){
  var environments = database.environments;
  var apps = database.applications;
  var $table = $('#reservations');

  var $environments = $("#environments");
  var $tableHeader = $('<thead><tr><th>Applications</th></tr></thead>');

  environments.forEach(function(env){
    $('<th>', {text: env.name}).appendTo($tableHeader.find('tr'));
  });

  $table.append($tableHeader);

  apps.forEach(function(a){

    var markup = `<tbody>
                    <tr>
                      <td class='application-name'>
                        ${a.name}
                          <div class='toolbar'>
                            <span class='tool-item'>
                              <a href='${GITHUB_URL_BASE}${a.repo}'>
                                <i class='fa fa-github fa-2x'> </i>
                              </a>
                            </span>
                          </div>
                      </td>`;

    environments.forEach(function(env){
      var reservation = database.getReservation(a.id, env.id);
      let tpl = _.template(cellTemplate);
      var cellHtml = tpl({reservation: reservation, e: env, a: a});
      markup += `<td id='${env.name}-${a.name}'>${cellHtml}</td>`;
    });

    markup += '</tr></tbody>';
    $table.append(markup);
  });

  $environments.append($table);
}

function connectionSuccess() {
  $('.info-section')
    .css('display', 'block')
    .removeClass('connection-error')
    .addClass('connection-success')
    .html('Real-time connection established ' + _.sample(positiveFaces))
    .delay(5000)
    .fadeOut('slow');
}

function connectionError() {
  $('.info-section')
    .css('display', 'block')
    .removeClass('connection-success')
    .addClass('connection-error')
    .html('Real-time connection lost ' + _.sample(negativeFaces));
}

function connect(database) {
  let socket = new Socket("/socket", {params: {guardian_token: token}});
  socket.connect();

  socket.onOpen(connectionSuccess);
  socket.onClose(connectionError);
  socket.onError(connectionError);

  // Now that you are connected, you can join channels with a topic:
  let channel = socket.channel("reservations:lobby", {})
  $("table").on("click", "td a[data-action]", function(e){
    var $target = $(this);
    var cellData = $target.parents('.environment').data();

    let action = $target.data('action');

    var data = {
      environment_id: cellData.environmentId,
      application_id: cellData.applicationId
    };

    console.log('sending message', data);
    channel.push(`action:${action}`, data);
    e.preventDefault();
  });

  function updateCell(res, release){
    var updateCellId = `#${res.environment.name}-${res.application.name}`;
    let tpl = _.template(cellTemplate);
    var context = {reservation: res, e: res.environment, a: res.application};
    if(release){
      context.reservation = null;
    }
    var cellHtml = tpl(context);
    $(updateCellId).html(cellHtml);
  }

  channel.on("action:release", payload => {
    if(payload.status == 'success') {
      let res = payload.reservation;
      database.deleteReservation(res.application_id, res.environment_id);
      updateCell(res, true);
    }
    console.log(`[${Date()}] ${JSON.stringify(payload)}`);
  });

  channel.on("action:reserve", payload => {
    if(payload.status == 'success') {
      let res = payload.reservation;
      database.setReservation(res);
      updateCell(res, false);
    }
    console.log(`[${Date()}] ${JSON.stringify(payload)}`);
  });

  channel.join()
         .receive("ok", resp => { console.log("Joined successfully", resp) })
         .receive("error", resp => { console.log("Unable to join", resp) });
}

$(function(){
  run();

  $("table").on("mouseout", "td:not(.application-name)", function(){
    $(this).find('.toolbar').css('visibility', 'hidden');
  });

  $("table").on("mouseover", "td:not(.application-name)", function(){
    $(this).find('.toolbar').css({display: 'flex', visibility: 'visible'});
  });
});
