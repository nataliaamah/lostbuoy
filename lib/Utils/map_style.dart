const String mapStyle = '''
[
    {
        "featureType": "landscape",
        "elementType": "geometry.fill",
        "stylers": [
            { "color": "#c8e6c9" } // Light green for landscape areas
        ]
    },
    {
        "featureType": "landscape.man_made",
        "elementType": "geometry.fill",
        "stylers": [
            { "color": "#ffccbc" } // Soft orange for man-made areas
        ]
    },
    {
        "featureType": "landscape.man_made.buildings",
        "elementType": "geometry.fill",
        "stylers": [
            { "color": "#f8bbd0" } // Pink for buildings
        ]
    },
    {
        "featureType": "road",
        "elementType": "geometry.fill",
        "stylers": [
            { "color": "#bbdefb" } // Light blue for roads
        ]
    },
    {
        "featureType": "road.highway",
        "elementType": "geometry.fill",
        "stylers": [
            { "color": "#ffc107" } // Yellow for highways
        ]
    },
    {
        "featureType": "poi",
        "elementType": "geometry.fill",
        "stylers": [
            { "color": "#d1c4e9" } // Lavender for points of interest
        ]
    },
    {
        "featureType": "poi.park",
        "elementType": "geometry.fill",
        "stylers": [
            { "color": "#aed581" } // Green for parks
        ]
    },
    {
        "featureType": "water",
        "elementType": "geometry.fill",
        "stylers": [
            { "color": "#64b5f6" } // Light blue for water bodies
        ]
    },
    {
        "featureType": "road",
        "elementType": "geometry.stroke",
        "stylers": [
            { "visibility": "off" } // Remove road outlines for a cleaner look
        ]
    },
    {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
            { "color": "#7c4dff" } // Purple for POI labels
        ]
    },
    {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [
            { "color": "#000000" } // Black for road labels
        ]
    }
]
''';
