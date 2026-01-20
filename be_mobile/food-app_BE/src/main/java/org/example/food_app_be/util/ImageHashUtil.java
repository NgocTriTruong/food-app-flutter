package org.example.food_app_be.util;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;

public class ImageHashUtil {

    // Compute average hash (aHash) as 64-char string of '0'/'1'
    public static String averageHash(InputStream imageStream) throws IOException {
        BufferedImage img = ImageIO.read(imageStream);
        if (img == null) throw new IOException("Không đọc được ảnh");

        // Resize to 8x8
        BufferedImage resized = new BufferedImage(8,8, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = resized.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g.drawImage(img, 0,0,8,8, null);
        g.dispose();

        int[] gray = new int[64];
        int sum = 0;
        for (int y=0;y<8;y++){
            for (int x=0;x<8;x++){
                int rgb = resized.getRGB(x,y);
                int r = (rgb>>16)&0xff;
                int gcol = (rgb>>8)&0xff;
                int b = rgb & 0xff;
                int lum = (r*299 + gcol*587 + b*114) / 1000; // luma
                gray[y*8 + x] = lum;
                sum += lum;
            }
        }
        int avg = sum / 64;
        StringBuilder hash = new StringBuilder(64);
        for (int i=0;i<64;i++){
            hash.append(gray[i] >= avg ? '1' : '0');
        }
        return hash.toString();
    }

    // Hamming distance between two hash strings
    public static int hammingDistance(String a, String b){
        if (a == null || b == null) return Integer.MAX_VALUE;
        int len = Math.min(a.length(), b.length());
        int d = 0;
        for (int i=0;i<len;i++) if (a.charAt(i) != b.charAt(i)) d++;
        d += Math.abs(a.length() - b.length());
        return d;
    }
}
