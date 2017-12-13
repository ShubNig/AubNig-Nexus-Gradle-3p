package com.sinlov.aubnig.test.demo.data;

import org.junit.Assert;
import org.junit.Test;

/**
 * test random
 * <pre>
 *     sinlov
 *
 *     /\__/\
 *    /`    '\
 *  ≈≈≈ 0  0 ≈≈≈ Hello world!
 *    \  --  /
 *   /        \
 *  /          \
 * |            |
 *  \  ||  ||  /
 *   \_oo__oo_/≡≡≡≡≡≡≡≡o
 *
 * </pre>
 * Created by sinlov on 2017/12/14.
 */
public class RandomStringTest {

    @Test
    public void testGenerateString() throws Exception {
        String result = RandomString.generateString(10);
        int length = result.length();
        Assert.assertEquals(10, length);
    }

    @Test
    public void testGenerateNumberString() throws Exception {
        String result = RandomString.generateNumberString(8);
        System.out.println("result = " + result);
        long parseLong = Long.parseLong(result);
        System.out.println("parseLong = " + parseLong);
        Assert.assertTrue(parseLong < 100000000 && parseLong > 9999999);
    }

    @Test
    public void testGenerateMixString() throws Exception {
        String result = RandomString.generateMixString(10);
        int length = result.length();
        Assert.assertEquals(10, length);
    }

    @Test
    public void testGenerateLowerString() throws Exception {
        String result = RandomString.generateLowerString(10);
        int length = result.length();
        Assert.assertEquals(10, length);
    }

    @Test
    public void testGenerateUpperString() throws Exception {
        String result = RandomString.generateUpperString(10);
        int length = result.length();
        Assert.assertEquals(10, length);
    }

    @Test
    public void testGenerateZeroString() throws Exception {
        String result = RandomString.generateZeroString(10);
        int length = result.length();
        Assert.assertEquals(10, length);
    }

    @Test
    public void testToFixdLengthString() throws Exception {
        String result = RandomString.toFixdLengthString(123L, 4);
        int length = result.length();
        Assert.assertEquals(5, length);
    }

    @Test
    public void testToFixdLengthString2() throws Exception {
        String result = RandomString.toFixdLengthString(12, 4);
        int length = result.length();
        Assert.assertEquals(6, length);
    }
}
