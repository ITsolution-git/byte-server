$('.map-modal').on('shown.bs.modal', function () {
  handler = Gmaps.build('Google');
  handler.buildMap({
      provider: {
        center: new google.maps.LatLng(latitude, longitude),
        draggable: true
      },
      internal: {
        id: 'map'
      }
    },
    function(){
      var markers = handler.addMarkers([
        {
          "lat": latitude,
          "lng": longitude,
          "infowindow": rest_name
        }
      ],
      {
        draggable: true
      });
      handler.bounds.extendWith(markers);
      handler.getMap().setZoom(15);
      google.maps.event.addListener(markers[0].serviceObject, 'dragend', function() {
         updateFormLocation(this.getPosition());
      });
    }
  );
});

function updateFormLocation(latLng) {
  longitude = latLng.lng();
  latitude = latLng.lat();  
  $.ajax({
    url: '/restaurants/update_latLng',
    data: {id: rest_id, lat: latLng.lat(), lng: latLng.lng()},
    type: 'POST',
    
  });
}