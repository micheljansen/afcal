$(document).ready(function(){
  update_url();
  
  // show and hide some things
  $("#step_1_more_link").show();
  $("#step_1_additional_explanation").hide();

  $("#step_2_more_link").show();
  $("#step_2_additional_explanation").hide();
  
  // set hint in time input box if it's empty
  if($("#time").val() == "") {
    $("#time").val("HH:MM");
  }
  
  // clear the hint on first selection
  $("#time").one("focus", function () {
    $("#time").val("");
  });
  
  // set default states
  if(!$("#specific_time").attr("checked")) {
    $("#time").fadeTo(0, 0.25);
  }

  // add event handlers
  $("select,input").change(update_url);
  $("input").keyup(update_url);
  
  // event handler automatically selecting the proper bullet
  // when someone selects the time input field
  $("#time").focus(function () {
    $("#time").fadeTo(500, 1);
    $("#specific_time").attr("checked", "checked");
  });
  
  
  // fade the time input box in and out to indicate its relevance
  $("#allday").change(function () {
    $("#time").fadeTo(1000, 0.25);
  });
  
  $("#specific_time").change(function () {
    $("#time").fadeTo(500, 1);
    $("#time").focus();
  });
  
  // $("#target_url").hide();
  
  $("#step_1_more_link").click(function(event) {
    event.preventDefault();
    $("#step_1_additional_explanation").slideDown(500);
    $("#step_1_more_link").hide();
    // $("#step_1_less_link").show();
  });
  
  $("#step_2_more_link").click(function(event) {
    event.preventDefault();
    $("#step_2_additional_explanation").slideDown(500);
    $("#step_2_more_link").hide();
    // $("#step_1_less_link").show();
  });
  
  /*
  $("#step_1_less_link").click(function(event) {
    event.preventDefault();
    $("#step_1_additional_explanation").slideUp(500);
    $("#step_1_less_link").hide();
    $("#step_1_more_link").show();
  });
  */
});

function update_url() {
  var url = generate_url();
  $("#target_url a").attr("href", url).text(url);
}

function generate_url() {
  var postalcode = $("#postalcode").val()
  if(postalcode == "") {
    postalcode = "postcode"
  }
  
  var homenumber = $("#homenumber").val()
  if(homenumber == "") {
    homenumber = "huisnummer"
  }
  
  var url = base_url()+"/"+postalcode+"/"+homenumber+"/all.ics";
  
  // time and alarm are optional
  var time = null;
  if($("#specific_time").attr("checked")) {
    time = $("#time").val();
    if(time != "" && time != "HH:MM") {
      url += "?time="+time;
    }
    else {
      time = null;
    }
  }
  
  var alarm = null;
  if($("#alarm option:selected").val() != "disabled") {
    alarm = $("#alarm").val();
    url += (time == null ? "?" : "&");
    url += "alarm="+alarm
  }
  
  return url;
}