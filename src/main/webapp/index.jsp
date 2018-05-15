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

<style type="text/css">
.row-margin-bottom {
	margin-bottom: 20px;
}
</style>

<!-- HTML5 shim 和 Respond.js 是为了让 IE8 支持 HTML5 元素和媒体查询（media queries）功能 -->
<!-- 警告：通过 file:// 协议（就是直接将 html 页面拖拽到浏览器中）访问页面时 Respond.js 不起作用 -->
<!--[if lt IE 9]>
      <script src="<%=request.getContextPath()%>/bootstrap/js/html5shiv.min.js"></script>
      <script src="<%=request.getContextPath()%>/bootstrap/js/respond.min.js"></script>
    <![endif]-->

<script type="text/javascript"
	src="<%=request.getContextPath()%>/bootstrap/js/jquery.min.js"></script>
<script type="text/javascript"
	src="<%=request.getContextPath()%>/bootstrap/js/bootstrap.min.js"></script>
<%-- <script type="text/javascript"
	src="<%=request.getContextPath()%>/bootstrap/js/canvas2image.js"></script> --%>
<script type="text/javascript">
	$(function() {

		$("#btn").click(
				function() {
					$.ajax({
						type : "POST",//方法类型
						dataType : "json",//预期服务器返回的数据类型
						url : "qrcode/create",
						data : $('#qrcodeForm').serialize(),
						success : function(data) {
							if (data.isSuccess) {
								$("#img").attr("src",
										"data:image/png;base64," + data.img);
							}
						},
						error : function() {
							alert("异常！");
						}
					});
				});

		/**
		 * 下载图片 只做chrome浏览器,不兼容其他 ie真是坑爹
		 */
		if (/chrom(e|ium)/i.test(navigator.userAgent)&&!/iPhone|iPad|iPod|iOS|Android/i.test(navigator.userAgent)) {
			$("#downBtn").css('display', 'block');
			$("#downBtn").click(
					function() {
						var sampleImage = document.getElementById("img");
						if (sampleImage.getAttribute("src").lastIndexOf(
								"default.png") != -1) {
							return false;
						}
						var canvas = convertImageToCanvas(sampleImage);
						var url = canvas.toDataURL("image/png");
						$("#temp").attr("href", url).attr("download",
								"default.png");
						$("#temp span").trigger("click");
						/* 	var sampleImage = document.getElementById("img");
							if (sampleImage.getAttribute("src").lastIndexOf("default.png") != -1) {
								return false;
							}
							var canvas = convertImageToCanvas(sampleImage);
							var url = canvas.toDataURL("image/png");

							//var aLink = document.createElement('a');
							var aLink=document.getElementById("temp");
							aLink.download = "qrcode.png";
							aLink.href = url;
							if (document.createEventObject) {
								// IE浏览器支持fireEvent方法  
								var evt = document.createEventObject();
								aLink.fireEvent('onclick', evt)
							} else {
								// 其他标准浏览器使用dispatchEvent方法  
								var evt = document.createEvent("HTMLEvents");
								evt.initEvent("click", true, true);  
								aLink.dispatchEvent(evt);
							} */
					});
		}

		/**
		 * 根据图片生成画布
		 */
		function convertImageToCanvas(image) {
			var canvas = document.createElement("canvas");
			canvas.width = image.width;
			canvas.height = image.height;
			canvas.getContext("2d").drawImage(image, 0, 0);
			return canvas;
		}

		/* $("#downBtn").click(function() {
			var src = $("#img").attr("src");
			if (src.lastIndexOf("default.png") != -1) {
				return false;
			}
			var blob_ = dataURLtoBlob(src); // 用到Blob是因为图片文件过大时，在一部风浏览器上会下载失败，而Blob就不会
			var url;
			url = {
				name : "qrcode", // 图片名称不需要加.png后缀名
				src : blob_
			};

			if (window.navigator.msSaveOrOpenBlob) { // if browser is IE
				navigator.msSaveBlob(url.src, url.name + '.png');//filename文件名包括扩展名，下载路径为浏览器默认路径
			} else {
				var link = document.createElement("a");
				link.setAttribute("href", window.URL.createObjectURL(url.src));
				link.setAttribute("download", url.name + '.png');
				document.body.appendChild(link);
				link.click();
			}
		});

		function dataURLtoBlob(dataurl) {
			var arr = dataurl.split(','), mime = arr[0].match(/:(.*?);/)[1], bstr = atob(arr[1]), n = bstr.length, u8arr = new Uint8Array(
					n);
			while (n--) {
				u8arr[n] = bstr.charCodeAt(n);
			}
			return new Blob([ u8arr ], {
				type : mime
			});
		} */

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
		<form class="form-horizontal" role="form" id="qrcodeForm" action="#">
			<div class="form-group">
				<label for="firstname" class="col-sm-2 control-label">说出心里话：</label>
				<div class="col-sm-8">
					<textarea class="form-control" rows="10" name="contents"></textarea>
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
				class="img-thumbnail center-block row-margin-bottom"> <a id="temp"><span></span></a>
			<button type="button"
				class="btn btn-success center-block" id="downBtn"
				style="display: none;">下载二维码</button>
		</div>

	</div>
</body>
</html>
