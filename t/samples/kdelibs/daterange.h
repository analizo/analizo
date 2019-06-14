/*
file copied from kdelibs source-code from nepomuk/utils/ in order to add
automated tests for bug: https://github.com/analizo/analizo/issues/148

this file daterange.cpp and daterange.h was copied from commit 7f7af640fb (from
kdelibs git repository)

kdelibs git: https://github.com/KDE/kdelibs.git
*/

/*
   Copyright (c) 2009-2010 Sebastian Trueg <trueg@kde.org>

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License as
   published by the Free Software Foundation; either version 2 of
   the License or (at your option) version 3 or any later version
   accepted by the membership of KDE e.V. (or its successor approved
   by the membership of KDE e.V.), which shall act as a proxy
   defined in Section 14 of version 3 of the license.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#ifndef _DATE_RANGE_H_
#define _DATE_RANGE_H_

#include <QtCore/QDate>
#include <QtCore/QSharedDataPointer>

class QDebug;

/**
 * \class DateRange daterange.h DateRange
 *
 * \brief A simple data structure storing a start and an end date.
 *
 * %DateRange is a very simple data structure storing a start and an end date.
 * The really interesting parts are the static factory methods which take the
 * current calendar system into account and, thus, create accurate values.
 *
 * \author Sebastian Trueg <trueg@kde.org>
 */
class DateRange
{
public:
    /**
     * Create a new range
     */
    DateRange( const QDate& s = QDate(),
               const QDate& e = QDate() );

    /**
     * Copy constructor
     */
    DateRange( const DateRange& other );

    /**
     * Destructor
     */
    ~DateRange();

    /**
     * Make this range a copy of \p other
     */
    DateRange& operator=( const DateRange& other );

    /**
     * Start date of the range.
     */
    QDate start() const;

    /**
     * End date of the range.
     */
    QDate end() const;

    /**
     * Checks if both start and end are valid dates
     * and if end is after start.
     */
    bool isValid() const;

    /**
     * Set the start to \p date.
     */
    void setStart( const QDate& date );

    /**
     * Set the end to \p date.
     */
    void setEnd( const QDate& date );

    /**
     * \returns a DateRange with both start and end
     * dates set to QDate::currentDate()
     */
    static DateRange today();

    /**
     * The flags allow to change the result returned by several of the
     * static factory methods provided by DateRange such as thisWeek()
     * or thisMonth().
     */
    enum DateRangeFlag {
        /**
         * No flags.
         */
        NoDateRangeFlags = 0x0,

        /**
         * Exclude days that are in the future. thisWeek() for example
         * will not include the days in the week that come after the current
         * day.
         */
        ExcludeFutureDays = 0x1
    };
    Q_DECLARE_FLAGS( DateRangeFlags, DateRangeFlag )

    /**
     * Takes KLocale::weekStartDay() into account.
     * \sa DateRangeFlag
     */
    static DateRange thisWeek( DateRangeFlags flags = NoDateRangeFlags );

    /**
     * Takes KLocale::weekStartDay() into account.
     * \param flags ExcludeFutureDays does only makes sense for a date in the current week. For
     * future weeks it is ignored.
     * \sa DateRangeFlag
     */
    static DateRange weekOf( const QDate& date, DateRangeFlags flags = NoDateRangeFlags );

    /**
     * \return A DateRange which includes all days of the current month.
     *
     * \sa DateRangeFlag
     */
    static DateRange thisMonth( DateRangeFlags flags = NoDateRangeFlags );

    /**
     * \param flags ExcludeFutureDays does only makes sense for a date in the current month. For
     * future months it is ignored.
     * \return A DateRange which includes all days of the month in which
     * \p date falls.
     * \sa DateRangeFlag
     */
    static DateRange monthOf( const QDate& date, DateRangeFlags flags = NoDateRangeFlags );

    /**
     * \return A DateRange which includes all days of the current year.
     * \sa DateRangeFlag
     */
    static DateRange thisYear( DateRangeFlags flags = NoDateRangeFlags );

    /**
     * \param flags ExcludeFutureDays does only makes sense for a date in the current year. For
     * future years it is ignored.
     * \return A DateRange which includes all days of the year in which
     * \p date falls.
     * \sa DateRangeFlags
     */
    static DateRange yearOf( const QDate& date, DateRangeFlags flags = NoDateRangeFlags );

    /**
     * \return A DateRange which spans the last \p n days.
     */
    static DateRange lastNDays( int n );

    /**
     * \return A DateRange which spans the last \p n weeks,
     * including the already passed days in the current week.
     */
    static DateRange lastNWeeks( int n );

    /**
     * \return A DateRange which spans the last \p n months,
     * including the already passed days in the current month.
     */
    static DateRange lastNMonths( int n );

private:
    class Private;
    QSharedDataPointer<Private> d;
};

/**
 * Comparison operator
 *
 * \related DateRange
 */
bool operator==( const DateRange& r1, const DateRange& r2 );

/**
 * Comparison operator
 *
 * \related DateRange
 */
bool operator!=( const DateRange& r1, const DateRange& r2 );

/**
 * Allows using DateRange in hashed structures such as QHash or QMap.
 *
 * \related DateRange
 */
uint qHash( const DateRange& range );

/**
 * Debug streaming operator
 *
 * \relates DateRange
 */
QDebug operator<<( QDebug dbg, const DateRange& range );

Q_DECLARE_OPERATORS_FOR_FLAGS( DateRange::DateRangeFlags )

#endif
