const String mapStyle = '''
[
    {
        "featureType": "all",
        "elementType": "labels.text.fill",
        "stylers": [
            {
                "color": "#5d6e74" // Muted label color
            }
        ]
    },
    {
        "featureType": "landscape",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#e0e0e0" // Light gray for the landscape background
            }
        ]
    },
    {
        "featureType": "landscape.man_made",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#e0e0e0" // Matches the background for man-made areas
            }
        ]
    },
    {
        "featureType": "landscape.man_made.buildings",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#bcbcbc" // Darker gray for buildings
            }
        ]
    },
    {
        "featureType": "road",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#8a8f99" // Dark bluish-gray for roads
            }
        ]
    },
    {
        "featureType": "road",
        "elementType": "geometry.stroke",
        "stylers": [
            {
                "visibility": "off" // Removes unnecessary road outlines
            }
        ]
    },
    {
        "featureType": "road.highway",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#8a8f99" // Matches roads for uniformity
            }
        ]
    },
    {
        "featureType": "poi",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#e0e0e0" // Matches the landscape background
            }
        ]
    },
    {
        "featureType": "poi.school",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#c4c4c4" // Slightly darker for schools or important POIs
            }
        ]
    },
    {
        "featureType": "poi.park",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#d4d4d4" // Differentiated gray for parks
            }
        ]
    },
    {
        "featureType": "water",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#b8d0d3" // Softer light blue for water
            }
        ]
    }
]
''';
