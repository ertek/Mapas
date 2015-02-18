# Creado por Jorge Cedi Voirol el 13 de Febrero del 2015
# Opciones
# width
# height
# url
# yourPositionMarker
# pinsImage
# centerPin
require [
  "handlebars",
  "jquery",
  "jquery-cookie",
  "underscore",
  "backbone",
  "geoPosition",
  "async!http://maps.google.com/maps/api/js?sensor=false&v=3"],  (Handlebars) ->

  class MarkerModel extends  Backbone.Model
    initialize: ->
      return

  class MarkerList extends Backbone.Collection
    model: MarkerModel
    initialize: (opts)->
      if opts
        if opts.url
          @url = opts.url
    comparator: (marker)->
      marker.get 'id'


  class MapView extends Backbone.View
    # Inician opciones de la aplicación
    el: $ '#map'
    center: null
    map_id: "#my_map"
    map: null
    width: '100%'
    height: '100%'
    markers: []
    centerMarker: null
    bounds: null
    opts: {}


    storedPosition: ->
      lat = $.cookie 'lat'
      lng = $.cookie 'lng'
      if lat and lng
        return {lat, lng}
      else
        return false

    # Método de inicialización, agrega opciones a la aplicación
    initialize: (opts)->
      if opts
        @opts = opts
        if opts.width
          @width = opts.width
        if opts.height
          @height = opts.height
      else
        opts = {}

      if @storedPosition()
        @center = @storedPosition()
        if $(@el).length
          @render(opts)
      else
        @getBrowserGeolocation()


    # Renderiza html y mapa
    render: (opts)->
      # Creamos div para el mapa
      $(@el).append "<div id='#{@map_id}' style='width: #{@width}; height: #{@height};'></div>"
      # Opciones básicas del mapa
      map_options =
        zoom: 12
        center: new google.maps.LatLng @center.lat, @center.lng
      # Se crea el mapa y se agrega al dic creado anteriormente
      @map = new google.maps.Map document.getElementById(@map_id), map_options
      @bounds = new google.maps.LatLngBounds()
      if opts.yourPositionMarker == true
        @setCenterMarker(new google.maps.LatLng(@center.lat, @center.lng), opts.centerPin)
      if opts.url
        @fetchMarkers(opts.url, opts.pinsImage)

    setCenterMarker: (position, pinImage)->
      @centerMarker = new google.maps.Marker
        position: position
        map: @map
        icon: pinImage
        title: "Mi posición"
      @bounds.extend @centerMarker.getPosition()

    fetchMarkers: (url, pinsImage = null)->
      list = new MarkerList({
        url: url
      })
      self = @
      list.fetch
        success: ->
          infowindow = null
          list.forEach (m, i)->
            self.markers[m.get 'id'] = new google.maps.Marker
              position: new google.maps.LatLng m.get('lat'), m.get('lng')
              map: self.map
              title: "H",
              icon: pinsImage

            if self.opts.popupTemplate
              template = Handlebars.compile(self.opts.popupTemplate)
              contentString = template({m:m})
              console.log m

              google.maps.event.addListener self.markers[m.get 'id'], 'click', ->
                if infowindow
                  infowindow.close()
                #markers[business.get 'id'].setIcon regularBigPin
                #infowindow = new google.maps.InfoWindow
                #	content: contentString

                infowindow = new google.maps.InfoWindow
                  content: contentString
                  disableAutoPan: false


                infowindow.open self.map, self.markers[m.get 'id']
                last_model = m
                return

            self.bounds.extend self.markers[m.get 'id'].getPosition()
          self.map.fitBounds(self.bounds)

    # Obtiene ubicación mediante la biblioteca geoposition.js y la guarda en cookies y en la instancia de la aplicación
    getBrowserGeolocation: ->
      if geoPosition.init()
        geoPosition.getCurrentPosition @storePosition, @geolocationErrorCallback
      else
        console.log "Error al localizar"

    # Obtiene ubicación guardada en las cookies


    # Guarda la ubicación en las cookies
    storePosition: (position)->
      # TODO: Guardar la info de forma segura
      $.cookie 'lat', position.coords.latitude
      $.cookie 'lng', position.coords.longitude
      console.log @
      window.map_view.center =
        'lat': position.coords.latitude,
        'lng': position.coords.longitude
      window.map_view.render(window.map_view.opts)

    # Método de error para geoubicación
    geolocationErrorCallback: (err)->
      if err.code == 1
        console.log "Denied by user."

  # Inicia la aplicación
  window.MapView = MapView
  load_app()