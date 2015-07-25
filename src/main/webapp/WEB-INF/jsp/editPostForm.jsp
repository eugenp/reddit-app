<html>
<head>

<title>Schedule to Reddit</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css"/>
<link rel="stylesheet" th:href="@{/resources/datetime-picker.css}" />
<link rel="stylesheet" th:href="@{/resources/autocomplete.css}"/>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.11.2/jquery-ui.min.js"></script>
<script th:src="@{/resources/datetime-picker.js}"></script>
<script th:src="@{/resources/validator1.js}"></script>
<script th:src="@{/resources/moment.min.js}"></script>
<script th:src="@{/resources/moment-timezone-with-data.js}"></script>
<style type="text/css">
 .btn.disabled{
background-color: #ddd;
border-color: #ddd;
}

.btn.disabled:hover{
background-color: #ddd;
border-color: #ddd;
} 
</style>
</head>
<body>
<div th:include="header"/>

<div class="container">
<h1>Edit Scheduled Post</h1>
<form method="post" role="form" data-toggle="validator">
<div class="row">
<input type="hidden" id="id" name="id"/>
<input type="hidden" name="submissionResponse" />
<input type="hidden" name="redditID" />
<input type="hidden" name="Sent"/>

<div class="form-group">
    <label class="col-sm-3">Title</label>
    <span class="col-sm-9"><input name="title" placeholder="title" class="form-control" required="required" data-minlength="3"/></span>
</div>
<br/><br/>
<div class="form-group">
    <label class="col-sm-3">Url</label>
    <span class="col-sm-9"><input name="url" type="url" placeholder="url" class="form-control"  required="required" data-minlength="3"/></span>
</div>
<br/><br/>  
<div class="form-group">
    <label class="col-sm-3">Subreddit</label>
    <span class="col-sm-9"><input id="sr" name="subreddit" placeholder="Subreddit" class="form-control"  required="required" data-minlength="3"/></span>
</div>
<br/><br/>
<div>
<label  class="col-sm-3">Send replies to my inbox</label>  
<span class="col-sm-9"> 
<input  type="checkbox" name="sendReplies" value="true"/>
</span> 
</div>
<br/><br/>
<div>
<span class="col-sm-2"><a href="#" class="btn btn-default" onclick="checkIfAlreadySubmitted()">Check if already submitted</a></span>
<span class="col-sm-1"></span>
<span class="col-sm-9"><span id="checkResult" class="alert alert-info" style="display:none"></span></span>
</div>
<br/><br/>
<hr/>
<br/>

<div th:include="resubmit"/>

<br/><br/>
<label class="col-sm-3">Submission Date (<span id="timezone" sec:authentication="principal.user.preference.timezone">UTC</span>)</label>
<div class="col-sm-5"><input id="date" name="date" class="form-control" readonly="readonly"/></div><div class="col-sm-4"><a class="btn btn-default" onclick="togglePicker()" style="font-size:16px;padding:8px 12px"><i class="glyphicon glyphicon-calendar"></i></a></div>
    <script type="text/javascript">
    /*<![CDATA[*/
        $(function(){
            $('*[name=date]').appendDtpicker({"inline": true});
            $('*[name=date]').handleDtpicker('hide');
        });
        var toggle = "show";
        function togglePicker(){
            $('*[name=date]').handleDtpicker(toggle);
            toggle = toggle=="show"?"hide":"show";
        }
        /*]]>*/
    </script>

    <br/><br/>
    
    <div class="col-sm-12"><button id="submitBut" type="submit" class="btn btn-primary">Save Changes</button></div>
   </div>
</form>
</div>
</body>
<script th:inline="javascript">
  $(function() {
	$('form').validator();
    $( "#sr" ).autocomplete({
      source: "../api/subredditAutoComplete"
    });
    
    $("input[name='url'],input[name='sr']").focus(function (){
        $("#checkResult").hide();
    });
    
    loadPost();
    
  });
  
  function loadPost(){
	  var arr = window.location.href.split("/");
	  var id = arr[arr.length-1];
	  
	  $.get("../api/scheduledPosts/"+id, function (data){
          $.each(data, function(key, value) {
              if(value == true){
                  $('*[name="'+key+'"]')[0].checked=true;
              }
              if(value != false){
                  $('*[name="'+key+'"]').val(value);
              }
          });
          $("#date").val(loadDate(data.submissionDate));
      });
  }
  
  function loadDate(dateVal){
	  console.log($("#date").val());
      var serverTimezone = [[${#dates.format(#calendars.createToday(), 'z')}]];
      var serverDate = moment.tz(dateVal, serverTimezone);
      var clientDate = serverDate.clone().tz($("#timezone").html());
      var myformat = "YYYY-MM-DD HH:mm";
      return clientDate.format(myformat);
  }
</script>
<script>
/*<![CDATA[*/
function checkIfAlreadySubmitted(){
    var url = $("input[name='url']").val();
    var sr = $("input[name='sr']").val();
    console.log(url);
    if(url.length >2 && sr.length > 2){
        $.post("../api/checkIfAlreadySubmitted",{url: url, sr: sr}, function(data){
            var result = JSON.parse(data);
            if(result.length == 0){
                $("#checkResult").show().html("Not submitted before");
            }else{
                $("#checkResult").show().html('Already submitted <b><a target="_blank" href="http://www.reddit.com'+result[0].data.permalink+'">here</a></b>');
            }
        });
    }
    else{
        $("#checkResult").show().html("Too short url and/or subreddit");
    }
}           
/*]]>*/          
</script>

<script>
/*<![CDATA[*/
$("#submitBut").click(function(event) {
    event.preventDefault();
    editPost();
});

function editPost(){
	var id = $("#id").val();
    var data = {};
	$('form').serializeArray().map(function(x){data[x.name] = x.value;});
    console.log(JSON.stringify(data));
	$.ajax({
        url: "../api/scheduledPosts/"+id+"?date="+$("#date").val(),
        data: JSON.stringify(data),
        type: 'PUT',
        contentType:'application/json'
        	
    }).done(function() {
    	window.location.href="../scheduledPosts";
    })
    .fail(function(error) {
    	alert(error.responseText);
    }); 
}
/*]]>*/  
</script>
</html>