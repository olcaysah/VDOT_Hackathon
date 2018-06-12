I developed a [web application of toll-based route guidance](https://devpost.com/software/web-application-of-toll-based-route-guidance) for vdot hackathon. 

I want to note that this project has not been completed yet. When I have time, I will finish it.

In order to use this code you need Google Maps Api and Smarterroads.org api key.

The keys can be added into the keys.csv file. I included a sample file (keys_example.csv) but it needs to be renamed as keys.csv

Toll data has been parsed real time from [SmarterRoads Data Portal](http://smarterroads.org), [travel time](https://developers.google.com/maps/documentation/distance-matrix/intro) and [direction](https://developers.google.com/maps/documentation/directions/intro) data parsed from [Google Maps Api](https://cloud.google.com/maps-platform/). 

When the user enter origin and destination locations, parsed data analyzed and suggests multiple route options with the tolling information. User can select desired route option for the destination.

The web application written in R with shiny package. Leaflet map has been used for displaying the waypoints of selected route.
