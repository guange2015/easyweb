live = (function(){


  function ajaxGetScript(url){
  //创建xmlhttprequest 对象
  if(window.XMLHttpRequest){
    var xhr = new XMLHttpRequest();
  }else if(window.ActiveXobject){
    var xhr = new ActiveXobject("Msxml2.XMLHTTP");
  }
  //xmlhttprequest状态处理
  xhr.onreadystatechange = function(){
    switch (xhr.readyState) {
      case 0:
        // document.getElementById("div").innerHTML+="1.请求未初始化（在调用 open() 之前 <br />";
      break;
      case 1:
        // document.getElementById("div").innerHTML+="2.请求已提出（调用 send() 之前）<br />";
      break;
      case 2:
        // document.getElementById("div").innerHTML+="3.请求已发送（这里通常可以从响应得到内容头部）<br />";
      break;
      case 3:
        // document.getElementById("div").innerHTML+="4.请求处理中（响应中通常有部分数据可用，但是服务器还没有完成响应）<br />";
      break;
      case 4:
        // document.getElementById("div").innerHTML+="5.请求已完成（可以访问服务器响应并使用它）<br />";
        //加载完毕
        if(xhr.status == 200 || xhr.status == 0){
          //正常加载,调用回调函数
          createScript(xhr.responseText);
        }else{
          //文件不存在
          // alert("文件不存在");  
        }
      break;
    }  
  }
  //发送请求
  xhr.open("get",url,true);
  xhr.send(null);
}

//createScript
function createScript(responseText){
  //动态创建script，并加载请求回来的JS数据
  var oHead = document.getElementsByTagName("head")[0];
  var oScript = document.createElement("script");
  oScript.type = "text/javascript";
  oScript.text = responseText;
  oHead.appendChild(oScript);
  
  var socket = io.connect('http://localhost:3002/livereload');
  socket.on('change', function(data) {
    console.log(data);
    var event = new CustomEvent('change', { 'detail': data });
    document.dispatchEvent(event);
    // http://stackoverflow.com/questions/5404839/how-can-i-refresh-a-page-with-jquery
    // instead of window.location.reload(); Some of the browsers like Firefox opens ConfirmBox for resend.If you reload after post request.
    // window.location = window.location.pathname;
  });
}

ajaxGetScript("/socket.io/socket.io.js");
  
})();
  