package ru.krista.crypt.crypt_signature;

import ru.krista.io.asn1.core.Asn1Tag;
import ru.krista.io.asn1.core.Primitive;
import ru.krista.io.asn1.core.Tag;
import sun.util.calendar.CalendarDate;
import sun.util.calendar.CalendarSystem;
import sun.util.calendar.Gregorian;

import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.SimpleTimeZone;

@Asn1Tag(value = Tag.GENERALIZED_TIME)
public class GeneralizedTime extends Primitive {
    public static GeneralizedTime now() {
        return withDate(new Date());
    }

    public static GeneralizedTime withDate(Date time) {
        GeneralizedTime gt = new GeneralizedTime();
        SimpleDateFormat dateF = new SimpleDateFormat("yyyyMMddHHmmss'Z'");
        dateF.setTimeZone(new SimpleTimeZone(0, "Z"));
        gt.setContent(dateF.format(time).getBytes(StandardCharsets.UTF_8));
        return gt;
    }

    private byte dig(byte value) {
        return (byte) (value - '0');
    }

    public Date asDate() throws UnsupportedEncodingException {
        return asDate(true);
    }

    public Date asDate(boolean isGeneralized) throws UnsupportedEncodingException {
        byte[] value = getContent();
        int year;
        int pos = 0;
        if (isGeneralized) {
            year = 1000 * dig(value[pos++]);
            year += 100 * dig(value[pos++]);
            year += 10 * dig(value[pos++]);
            year += dig(value[pos++]);
        } else {
            year = 10 * dig(value[pos++]);
            year += dig(value[pos++]);
            year += (year < 50) ? 2000 : 1900;
        }

        int month = 10 * dig(value[pos++]);
        month += dig(value[pos++]);
        int day = 10 * dig(value[pos++]);
        day += dig(value[pos++]);
        int hour = 10 * dig(value[pos++]);
        hour += dig(value[pos++]);
        int min = 10 * dig(value[pos++]);
        min += dig(value[pos++]);

        int mills = 0;
        int sec;
        int rest = value.length - pos;
        if (rest > 2 && rest < 12) {
            sec = 10 * dig(value[pos++]);
            sec += dig(value[pos++]);

            if (value[pos] == '.' || value[pos] == ',') {
                ++pos;
                int len = 0;

                //todo: выход за переделы диапазона тоже надо контролировать
                for (int i = pos; value[i] != 'Z' && value[i] != '.' && value[i] != ','; i++, len++) ;

                if (len > 0) {
                    switch (len) {
                        case 1:
                            mills += 100 * dig(value[pos++]);
                            break;
                        case 2:
                            mills += 100 * dig(value[pos++]);
                            mills += 10 * dig(value[pos++]);
                            break;
                        case 3:
                            mills += 100 * dig(value[pos++]);
                            mills += 10 * dig(value[pos++]);
                            mills += dig(value[pos++]);
                            break;
                        default:
                            //20181009105650.162691Z - такой ответ пришел от сервера http://freetsa.org/tsr

                            mills += 100 * dig(value[pos++]);
                            mills += 10 * dig(value[pos++]);
                            mills += dig(value[pos++]);
                            pos += (len - 3);
                            break;
                            //throw new UnsupportedEncodingException("Для миллисекунд точность выше 3 знаков не поддерживается");
                    }
                }
            }
        } else {
            sec = 0;
        }

        if (month != 0 && day != 0 && month <= 12 && day <= 31 && hour < 24 && min < 60 && sec < 60) {
            Gregorian gregorianCalendar = CalendarSystem.getGregorianCalendar();
            CalendarDate calendarDate = gregorianCalendar.newCalendarDate(null);
            calendarDate.setDate(year, month, day);
            calendarDate.setTimeOfDay(hour, min, sec, mills);
            long time = gregorianCalendar.getTime(calendarDate);
            rest = value.length - pos;
            //Вычисление смещения временной зоны
            if (rest != 1 && rest != 5) {
                throw new UnsupportedEncodingException("Ошибка формата временной зоны");
            } else {
                switch (value[pos++]) {
                    case '+':
                        min = 10 * dig(value[pos++]);
                        min += dig(value[pos++]);
                        sec = 10 * dig(value[pos++]);
                        sec += dig(value[pos]);
                        if (min >= 24 || sec >= 60)
                            throw new UnsupportedEncodingException("Ошибка формата временной зоны +hhmm");
                        time -= (long) ((min * 60 + sec) * 60 * 1000);
                        break;
                    case '-':
                        min = 10 * dig(value[pos++]);
                        min += dig(value[pos++]);
                        sec = 10 * dig(value[pos++]);
                        sec += dig(value[pos]);
                        if (min >= 24 || sec >= 60)
                            throw new UnsupportedEncodingException("Ошибка формата временной зоны -hhmm");
                        time += (long) ((min * 60 + sec) * 60 * 1000);
                    case 'Z':
                        break;
                    default:
                        throw new UnsupportedEncodingException("Ошибка формата временной зоны");
                }

                return new Date(time);
            }
        } else
            throw new UnsupportedEncodingException();
    }

}
