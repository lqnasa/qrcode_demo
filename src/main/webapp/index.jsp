<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<base href="<%=basePath%>">
<title>二维码生成</title>

<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<link rel="stylesheet"
	href="<%=request.getContextPath()%>/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/bootstrap/css/bootstrap-theme.min.css">
<script type="text/javascript"
	src="<%=request.getContextPath()%>/bootstrap/js/jquery.min.js"></script>
<script type="text/javascript"
	src="<%=request.getContextPath()%>/bootstrap/js/bootstrap.min.js"></script>


<script type="text/javascript">
	$(function() {

		$("#btn").click(function() {
		
			 $.ajax({
                type: "POST",//方法类型
                dataType: "json",//预期服务器返回的数据类型
                url: "<%=request.getContextPath()%>/qrcode/create" ,//url
                data: $('#qrcodeForm').serialize(),
                success: function (data) {
                    console.log(data);//打印服务端返回的数据(调试用)
                    if(data.isSuccess){
                    	$("#img").attr("src","data:image/jpg;base64,"+data.img);
                    }
                    
                },
                error : function() {
                    alert("异常！");
                }
            });


		});


	});
</script>


</head>
<body>

	<nav class="navbar navbar-default">
		<div class="container-fluid">
			<div class="navbar-header">
				<p class="navbar-text">说出您想对她（他）说的话，生成二维码图片。 by coderLee23</p>
			</div>
		</div>
	</nav>

	<div class="container-fluid">
		<form class="form-horizontal" role="form" id="qrcodeForm" action="#" >
			<div class="form-group">
				<label for="firstname" class="col-sm-2 control-label">说出心里话：</label>
				<div class="col-sm-8">
					<textarea class="form-control" rows="10" name="contents" ></textarea>
				</div>
			</div>
			<div class="form-group">
				<div class="col-sm-offset-2 col-sm-8">
					<button type="button" class="btn btn-default pull-right" id="btn">生成二维码</button>
				</div>
			</div>
		</form>

		<div class="col-sm-offset-2 col-sm-8">
			<img id="img" src="<%=request.getContextPath()%>/img/default.png"
				class="img-thumbnail center-block">
		</div>

	</div>
</body>
</html>
