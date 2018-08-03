/*
 * Copyright 2017 Analog Devices, Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with GNU Radio; see the file LICENSE.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

#ifndef SPECTRUM_MARKER_H
#define SPECTRUM_MARKER_H

#include <qwt_plot_marker.h>

namespace adiscope {

class SpectrumMarker: public QwtPlotMarker
{
public:
	SpectrumMarker(const QString& title, bool movable = true);
	SpectrumMarker(const QString &title, int xAxisId, int yAxisId,
		bool movable = true);
	virtual ~SpectrumMarker();

	QColor defaultColor() const;
	void setDefaultColor(const QColor&);

	bool selected() const;
	void setSelected(bool on);

	bool movable() const;
	void setMovable(bool on);

	QPoint plotValueToPixels(const QPointF& point) const;
	QPointF plotPixelsToValue(const QPoint& point) const;

	QRect boundingRectPixels() const;

private:
	int m_xAxis;
	int m_yAxis;
	bool m_selected;
	bool m_movable;
	QColor m_default_color;
};

} /* namespace adiscope */

#endif /* SPECTRUM_MARKER_H */
