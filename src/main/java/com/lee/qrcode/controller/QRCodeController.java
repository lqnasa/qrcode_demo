package com.lee.qrcode.controller;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.util.Base64Utils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import net.coobird.thumbnailator.Thumbnails;
import net.coobird.thumbnailator.geometry.Positions;

@Controller
public class QRCodeController {

	private static final Integer WIDTH = 300;
	private static final Integer HEIGHT = 300;
	private static final String FORMAT_NAME = "png";
	private static int onFrontColor = 0xFFE40087;
	// private static int onBlackColor = 0xFF000000; // 前景色
	private static int offColor = 0xFFFFFFFF; // 背景色
	private static int topLeftColor = 0xFF2CA855; // 背景色
	private static int topRightColor = 0xFFF7761C; // 背景色
	private static int bottomLeftColor = 0xFFDB4669; // 背景色

	private static final int alpha = 0xff; // 分离imageB象素好相加
	private static final int red = (onFrontColor >> 16) & 0xff;
	private static final int green = (onFrontColor >> 8) & 0xff;
	private static final int blue = (onFrontColor) & 0xff;

	private static final Map<EncodeHintType, Object> hints = new HashMap<EncodeHintType, Object>();

	private static BufferedImage watermarkImage = null;

	static {
		hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
		hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.Q);
		hints.put(EncodeHintType.MARGIN, 1);

		InputStream resourceAsStream = QRCodeController.class.getClassLoader().getResourceAsStream("img/love.jpg");
		try {
			watermarkImage = Thumbnails.of(resourceAsStream).size(60, 60).asBufferedImage();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (resourceAsStream != null) {
				try {
					resourceAsStream.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}

	}

	@RequestMapping(value = "/qrcode/create", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> createQRCode(@RequestParam String contents, HttpServletResponse response) {

		ByteArrayOutputStream byteArrayOutputStream = null;
		Map<String, Object> resultMap = new HashMap<>();
		MultiFormatWriter multiFormatWriter = new MultiFormatWriter();
		try {

			BitMatrix bitMatrix = multiFormatWriter.encode(contents, BarcodeFormat.QR_CODE, WIDTH, HEIGHT, hints);

			BufferedImage qrCodeBuf = toBufferedImage(bitMatrix);// MatrixToImageWriter.toBufferedImage(bitMatrix);
			// 添加水印，叠加logo在中间
			BufferedImage logoQrCodeBuf = Thumbnails.of(qrCodeBuf).size(WIDTH, HEIGHT)
					.watermark(Positions.CENTER, watermarkImage, 1f).asBufferedImage();

			// MatrixToImageWriter.writeToPath(bitMatrix, FORMAT_NAME, new
			// File("D://qrcode.png").toPath());
			// 写到本地
			// ImageIO.write(logoQrCodeBuf, FORMAT_NAME, new
			// File("D://qrcode.png"));
			// 直接回写
			// ImageIO.write(logoQrCodeBuf, FORMAT_NAME,
			// response.getOutputStream());

			// 生成base64
			byteArrayOutputStream = new ByteArrayOutputStream();
			ImageIO.write(logoQrCodeBuf, FORMAT_NAME, byteArrayOutputStream);
			String base64Str = Base64Utils.encodeToString(byteArrayOutputStream.toByteArray());

			resultMap.put("isSuccess", true);
			resultMap.put("img", base64Str);

		} catch (Exception e) {
			e.printStackTrace();
			resultMap.put("isSuccess", false);
		} finally {
			if (byteArrayOutputStream != null) {
				try {
					byteArrayOutputStream.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return resultMap;
	}

	public static Integer getMinSquareLength(BitMatrix matrix, int width, int height) {
		boolean temp = false;
		for (int x = 0; x < width; x++) {
			for (int y = 0; y < height; y++) {
				if (matrix.get(x, y)) {
					temp = true;
				}
				if (!matrix.get(x, y) && temp) {
					return y;
				}
			}
		}
		return 0;
	}

	public static BufferedImage toBufferedImage(BitMatrix matrix) {
		int width = matrix.getWidth();
		int height = matrix.getHeight();

		Integer minSquareLength = getMinSquareLength(matrix, width, height);

		BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);

		for (int x = 0; x < width; x++) {
			for (int y = 0; y < height; y++) {
				if (x > 0 && x < minSquareLength && y > 0 && y < minSquareLength) {
					image.setRGB(x, y, matrix.get(x, y) ? topLeftColor : offColor);
				} else if (x > 0 && x > width - minSquareLength - 1 && y > 0 && y < minSquareLength) {
					image.setRGB(x, y, matrix.get(x, y) ? topRightColor : offColor);
				} else if (x > 0 && x < minSquareLength && y > 0 && y > height - minSquareLength - 1) {
					image.setRGB(x, y, matrix.get(x, y) ? bottomLeftColor : offColor);
				} else {
					//渐变算法
					int newRed = (int) Math.round(red * (1 - (double) y / (double) height)); // 象素按每种颜色的衰减相加
					int newGreen = (int) Math.round(green * (1 - (double) y / (double) height));
					int newBlue = (int) Math.round(blue * (1 - (double) y / (double) height));
					image.setRGB(x, y,
							matrix.get(x, y) ? (alpha << 24) | (newRed << 16) | (newGreen << 8) | (newBlue) : offColor);

				}
			}
		}
		return image;
	}

}
