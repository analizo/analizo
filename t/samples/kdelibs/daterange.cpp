/*

**ANALIZO NOTE**

This file was copied from kdelibs project for testing analizo features.

The original file was copied as-is to create automated tests on analizo side
fixing the bug below.

- https://github.com/analizo/analizo/issues/148

GitHub kdelibs repository:

- https://github.com/KDE/kdelibs.git

Original file was copied from the commit 668ef94b2b from kdelibs git repository
and it is located inside kdelibs repository on the path below.

- nepomuk/utils/daterange.cpp

Link to the original file on GitHub:

- https://github.com/KDE/kdelibs/blob/668ef94b2b861f7ec4aa20941bcb6493bc4367be/nepomuk/utils/daterange.cpp

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

#include "daterange.h"

#include "kglobal.h"
#include "klocale.h"
#include "kcalendarsystem.h"

#include <QtCore/QSharedData>
#include <QtCore/QDebug>


class DateRange::Private : public QSharedData
{
public:
    QDate m_start;
    QDate m_end;
};


DateRange::DateRange( const QDate& s,
                      const QDate& e )
    : d(new Private())
{
    d->m_start = s;
    d->m_end = e;
}


DateRange::DateRange( const DateRange& other )
{
    d = other.d;
}


DateRange::~DateRange()
{
}


DateRange& DateRange::operator=( const DateRange& other )
{
    d = other.d;
    return *this;
}


QDate DateRange::start() const
{
    return d->m_start;
}


QDate DateRange::end() const
{
    return d->m_end;
}


bool DateRange::isValid() const
{
    return KGlobal::locale()->calendar()->isValid(d->m_start) && KGlobal::locale()->calendar()->isValid(d->m_end) && d->m_start <= d->m_end;
}


void DateRange::setStart( const QDate& date )
{
    d->m_start = date;
}


void DateRange::setEnd( const QDate& date )
{
    d->m_end = date;
}


// static
DateRange DateRange::today()
{
    const QDate today = QDate::currentDate();
    return DateRange( today, today );
}


namespace {
    /**
     * Put \p day into the week range 1...weekDays
     */
    int dateModulo( int day, int weekDays ) {
        day = day%weekDays;
        if ( day == 0 )
            return weekDays;
        else
            return day;
    }
}

// static
DateRange DateRange::thisWeek( DateRangeFlags flags )
{
    return weekOf( QDate::currentDate(), flags );
}


// static
DateRange DateRange::weekOf( const QDate& date, DateRangeFlags flags )
{
    const int daysInWeek = KGlobal::locale()->calendar()->daysInWeek( date );
    const int weekStartDay = KGlobal::locale()->weekStartDay();
    const int weekEndDay = dateModulo( weekStartDay+daysInWeek-1, daysInWeek );
    const int dayOfWeek = KGlobal::locale()->calendar()->dayOfWeek( date );

    DateRange range;

    if ( weekStartDay > dayOfWeek )
        range.d->m_start = date.addDays( - (dayOfWeek + daysInWeek - weekStartDay) );
    else
        range.d->m_start = date.addDays( - (dayOfWeek - weekStartDay) );

    if ( weekEndDay < dayOfWeek )
        range.d->m_end = date.addDays( weekEndDay + daysInWeek - dayOfWeek );
    else
        range.d->m_end = date.addDays( weekEndDay - dayOfWeek);

    if( flags & ExcludeFutureDays ) {
        const QDate today = QDate::currentDate();
        if( range.start() <= today && range.end() >= today )
            range.setEnd( today );
    }

    return range;
}


// static
DateRange DateRange::thisMonth( DateRangeFlags flags )
{
    return monthOf( QDate::currentDate(), flags );
}


// static
DateRange DateRange::monthOf( const QDate& date, DateRangeFlags flags )
{
    DateRange range( KGlobal::locale()->calendar()->firstDayOfMonth( date ),
                     KGlobal::locale()->calendar()->lastDayOfMonth( date ) );
    if( flags & ExcludeFutureDays ) {
        const QDate today = QDate::currentDate();
        if( range.start() <= today && range.end() >= today )
            range.setEnd( today );
    }
    return range;
}



// static
DateRange DateRange::thisYear( DateRangeFlags flags )
{
    return yearOf( QDate::currentDate(), flags );
}


// static
DateRange DateRange::yearOf( const QDate& date, DateRangeFlags flags )
{
    DateRange range( KGlobal::locale()->calendar()->firstDayOfYear( date ),
                     KGlobal::locale()->calendar()->lastDayOfYear( date ) );
    if( flags & ExcludeFutureDays ) {
        const QDate today = QDate::currentDate();
        if( date.year() == today.year() )
            range.setEnd( today );
    }
    return range;
}


// static
DateRange DateRange::lastNDays( int n )
{
    DateRange range = today();
    range.setStart( range.start().addDays( -n ) );
    return range;
}


// static
DateRange DateRange::lastNWeeks( int n )
{
    // This week is the first week
    DateRange range = thisWeek( false );

    // go into the previous week
    range.setStart( range.start().addDays( -1 ) );

    // from that on we go back n-1 weeks, for each of those we call daysInWeek
    for( int i = 1; i < n; ++i ) {
        QDate weekDay = range.start();
        weekDay.addDays( -KGlobal::locale()->calendar()->daysInWeek( weekDay ) );
        range.setStart( weekDay );
    }

    // go back to the start of the next week, thus, reverting the -1 we did above
    range.setStart( range.start().addDays( 1 ) );

    return range;
}


// static
DateRange DateRange::lastNMonths( int n )
{
    // This month is the first month
    DateRange range = thisMonth( false );

    // move the start n-1 months back
    range.setStart( KGlobal::locale()->calendar()->addMonths(range.start(), n-1 ) );

    return range;
}


bool operator==( const DateRange& r1, const DateRange& r2 )
{
    return r1.start() == r2.start() && r1.end() == r2.end();
}


bool operator!=( const DateRange& r1, const DateRange& r2 )
{
    return r1.start() != r2.start() || r1.end() != r2.end();
}


uint qHash( const DateRange& range )
{
    return qHash( range.start() ) ^ qHash( range.end() );
}

QDebug operator<<( QDebug dbg, const DateRange& range )
{
    dbg.nospace() << "DateRange(" << range.start() << range.end() << ")";
    return dbg;
}
