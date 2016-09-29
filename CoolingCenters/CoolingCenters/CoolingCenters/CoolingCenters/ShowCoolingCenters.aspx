<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ShowCoolingCenters.aspx.cs" Inherits="CoolingCenters.ShowCoolingCenters" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Cooling Centers Locations</title>
    <script src="Content/Script/jquery-3.1.1.js"></script>
    <style type="text/css">
        html
        {
            height: 100%;
        }

        body
        {
            height: 100%;
            margin: 0;
            padding: 0;
        }

        #map
        {
            height: 100%;
        }
    </style>
    <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=AIzaSyC6v5-2uaq_wusHDktM9ILcqIrlPtnZgEk&sensor=false">
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <p id="message"></p>
        <div id="map" style="width: 1920px; height: 1080px"></div>
    </form>
    <script type="text/javascript">
        var lat;
        var lon;
        var markers;
        var isUserLocation = false;

        $(document).ready(function () {
            $('#message').hide();
            $('#map').width($(document).width());
            $('#map').height($(document).height());
            getUserLocation();
            setTimeout(GetCoolingCenters, 3000);
            setTimeout(initialize, 3000);
        });

        function getUserLocation() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(showPosition, showError);
                //navigator.geolocation.getCurrentPosition(showPosition, showError, { maximumAge: 60000, timeout: 10000 });
            }
            else {
                $('#message').show();
                $("#message").html("Geolocation is not supported by this browser.");
            }

            function showPosition(position) {
                lat = position.coords.latitude;
                lon = position.coords.longitude;
            }
            function showError(error) {
                $('#message').show();
                if (error.code == 1) {
                    $("#message").html("User denied the request for Geolocation.");
                }
                else if (error.code == 2) {
                    $("#message").html("Location information is unavailable.");
                }
                else if (error.code == 3) {
                    $("#message").html("The request to get user location timed out.");
                }
                else {
                    $("#message").html("An unknown error occurred.");
                }
            }
        }

        function GetCoolingCenters() {
            $.ajax({
                url: 'http://localhost:54088/api/cs',
                type: "GET",
                dataType: "json",
                async: false,
                cache: false,
                success: function (data) {
                    markers = data;
                },
                error: function (jqXhr, textStatus, errorThrown) {
                    alert(jqXhr.status + '-' + errorThrown + '\n' + jqXhr.responseJSON.Message);
                }
            });
        }

        function initialize() {
            if (lat == undefined && lon == undefined) {
                lat = markers[0].Lat;
                lon = markers[0].Lon;
            }
            else { isUserLocation = true; }
            var mapOptions = {
                center: new google.maps.LatLng(lat, lon),
                zoom: 12,
                mapTypeId: google.maps.MapTypeId.ROADMAP
                //  marker:true
            };
            var infoWindow = new google.maps.InfoWindow();
            var map = new google.maps.Map(document.getElementById("map"), mapOptions);

            //markers.push({ "Address": "Your Location", "Lat": useLat, "Lon": useLon });
            for (i = 0; i < markers.length; i++) {
                var data = markers[i]
                var myLatlng = new google.maps.LatLng(data.Lat, data.Lon);
                var marker = new google.maps.Marker({
                    position: myLatlng,
                    map: map
                    //title: data.Address
                });
                (function (marker, data) {
                    google.maps.event.addListener(marker, "click", function (e) {
                        infoWindow.setContent(data.Address);
                        infoWindow.open(map, marker);
                    });
                })(marker, data);
            }

            if (isUserLocation == true) {
                //---Get Client Address From Lat and Long---
                var formatted_address = '';
                var latlng = new google.maps.LatLng(lat, lon);
                var geocoder = geocoder = new google.maps.Geocoder();
                geocoder.geocode({ 'latLng': latlng }, function (results, status) {
                    if (status == google.maps.GeocoderStatus.OK) {
                        if (results[0]) {
                            formatted_address = results[0].formatted_address;
                        }
                        else {
                            formatted_address = 'No results found';
                        }
                    }
                    else {
                        formatted_address = 'Geocoder failed due to: ' + status;
                    }
                });
                //----------------------------------------

                //---Set Client Location on Map with his Address---
                var usrmyLatlng = new google.maps.LatLng(lat, lon);
                var marker = new google.maps.Marker({
                    position: usrmyLatlng,
                    map: map,
                    //title: 'Your Location',
                    icon: pinSymbol('#3fbb14')
                });
                (function (marker, data) {
                    google.maps.event.addListener(marker, "click", function (e) {
                        infoWindow.setContent('<b>Your location</b><br />' + formatted_address);
                        infoWindow.open(map, marker);
                    });
                })(marker, data);
                //----------------------------------------

                //---Get nearest location from client location and set on Map---
                var closest = 0;
                var mindist = 99999;
                for (var i = 0; i < markers.length; i++) {
                    var dist = Haversine(markers[i].Lat, markers[i].Lon, lat, lon);
                    if (dist < mindist) {
                        closest = i;
                        mindist = dist;
                    }
                }
                var closetlatlng = new google.maps.LatLng(markers[closest].Lat, markers[closest].Lon);
                var marker = new google.maps.Marker({
                    position: closetlatlng,
                    map: map,
                    //title: markers[closest].Address,
                    icon: pinSymbol('#0053ff')
                });
                (function (marker, data) {
                    google.maps.event.addListener(marker, "click", function (e) {
                        infoWindow.setContent('<b>Nearest location to you.</b><br />' + markers[closest].Address);
                        infoWindow.open(map, marker);
                    });
                })(marker, data);
                //----------------------------------------
            }
        }

        function pinSymbol(color) {
            return {
                path: 'M 0,0 C -2,-20 -10,-22 -10,-30 A 10,10 0 1,1 10,-30 C 10,-22 2,-20 0,0 z M -2,-30 a 2,2 0 1,1 4,0 2,2 0 1,1 -4,0',
                fillColor: color,
                fillOpacity: 1,
                strokeColor: '#000',
                strokeWeight: 2,
                scale: 1,
            };
        }

        function Deg2Rad(deg) {
            return deg * Math.PI / 180;
        }

        function Haversine(lat1, lon1, lat2, lon2) {
            var R = 6372.8;
            var dLat = Deg2Rad(lat2 - lat1);
            var dLon = Deg2Rad(lon2 - lon1);

            var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
							Math.cos(Deg2Rad(lat1)) * Math.cos(Deg2Rad(lat2)) *
							Math.sin(dLon / 2) * Math.sin(dLon / 2);
            var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            var d = R * c;
            return d;
        }
    </script>
</body>
</html>
