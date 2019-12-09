// ENUMS
const PointType = {
    WAYPOINT: 0,
    ENDPOINT: 1,
};

const State = {
	CURSOR: 0,
	ADD_WAYPOINT: 1,
	ADD_ENDPOINT: 2,
	CONNECTION: 3
};

// dimensions of the image
const w = 2000, h = 2000;


var map = L.map('image-map', {
  minZoom: 0.5,
  maxZoom: 4,
  center: [0, 0],
  zoom: 0.5,
  crs: L.CRS.Simple
});

var currentFloor = 1;
var pin1 = null;


var corner1 = L.latLng(0,h/4);
var corner2 = L.latLng(w/4,0);
var bounds = L.latLngBounds(corner1, corner2);
map.setMaxBounds(bounds);

var waypointIcon = L.icon({
	iconUrl: 'img/marker-waypoint.png',
	iconSize:     [20, 20]
});

var incompleteIcon = L.icon({
	iconUrl: 'img/marker-incomplete.png',
	iconSize:     [20, 20]
});

var endpointIcon = L.icon({
	iconUrl: 'img/marker-endpoint.png',
	iconSize:     [20, 20]
});

var selectIcon = L.icon({
	iconUrl: 'img/marker-select.png',
	iconSize:     [20, 20]
});




var markers = [];
var state = State.CURSOR;

var img;


// LOGIC

$(".change-state").on('click', function(e){
	$("#form-marker").hide();
	$("#form-connection").hide();

	$$ = $(e.target);

	stateBtn = parseInt($$.attr('state'));

	console.log("Click on state:", stateBtn);

	if ($$.hasClass('btn-primary') || stateBtn == State.CURSOR) {
		setState(State.CURSOR);
	} else {
		if (stateBtn == State.ADD_WAYPOINT) {
			setState(State.ADD_WAYPOINT);
		} else if (stateBtn == State.ADD_ENDPOINT) {
			setState(State.ADD_ENDPOINT);
		} else {
			setState(State.CONNECTION);
		}

	}


});


function setState(stateBtn) {
	console.log("Change state from", state,'to', stateBtn);

	if (pin1 != null) {
		pin1.unselect();
	}

	pin1 = null;
	state = stateBtn;

	$(".change-state").each(function(_){
		el = $(this);
		el.removeClass('btn-primary');

		if (parseInt(el.attr('state')) == stateBtn) {
			el.addClass('btn-primary');
		}		
	});



}

$(".open-floor").on('click', function(e){
	$$ = $(e.target);

	floor = parseInt($$.attr('floor'));
	url = $$.attr('url');

	$(".open-floor").each(function(el){
		btn = $(this);
		btn.removeClass('btn-primary');
	})


	$$.addClass('btn-primary');

	console.log('floor', floor, 'url', url);

	openFloor(floor, url);
});

$(".open-floor").first().click();

function openFloor(floor, url){
	currentFloor = floor;
	$("h1").text("Floor "+ floor);
	
	markers.forEach(function(marker){
		map.removeLayer(marker._marker);
		marker.removeConnections();

	});

	if (img !== undefined) {
		map.removeLayer(img);
	}

	img = L.imageOverlay(url, bounds).addTo(map);

	img.bringToBack();

	markers.forEach(function(marker){
		if (marker.floor == floor) {
			marker.addToMap();
		}
	});

	markers.forEach(function(marker){
		if (marker.floor == floor) {
			marker.resetConnections();
		}
	});

	$("#form-marker").hide();
	$("#form-connection").hide();

}

//Add marker

map.on('click',
  function mapClickListen(e) {
  	if (!bounds.contains(e.latlng)) {
  		return;
  	}

  	if (state == State.ADD_WAYPOINT || state == State.ADD_ENDPOINT) {

	    var pos = imgPositionFromLatLng(e.latlng,4);
	    var type = PointType.ENDPOINT;
	    var id = "";

		if (state == State.ADD_WAYPOINT) {
			id = "waypoint_" + generateWaypointId();
			type = PointType.WAYPOINT;
		}

		console.log("ID way:", id);


	    var marker = new MarkerPoint(4, pos.x, pos.y, type, id, "", "", currentFloor);
	    marker.addToMap(map, bounds);
	    markers.push(marker);

	    // waitAdd = false;
	}
  }
);

function generateWaypointId() {
	var minId = 0;

	markers.forEach(function(marker) {
		if (marker.type == PointType.WAYPOINT) {
			var id = parseInt(marker.id.split("_")[1]);

			if (minId < id) {
				minId = id;
			}
		}
	});

	minId = minId + 1;

	
	return minId+"";	
}

function onStartDrag() {
	$("#form-marker").hide();
	$("#form-connection").hide();
}

function onClickMarker(marker) {
	$("#form-marker").hide();
	$("#form-connection").hide();

	console.log('onClickMarker:', marker, 'State:', state);
	switch(state) {
		case State.CURSOR: {
			editMarker(marker);
			break;
		}
		case State.CONNECTION: {
			if (!marker.hasId()) {
				alert('Marker has not ID');
			} else {
				if (pin1 == null) {
					console.log('Selected first pin:', marker);
					pin1 = marker;
					pin1.select();
				} else {
					if (pin1 != marker) {
						console.log('Selected second pin:', marker, 'first:', pin1);
						if (!pin1.connect(marker.id)) {
							alert('Connection failed');
						}
						pin1.unselect();
						pin1 = null;
					} else {
						alert('You cannot connect single marker with self');
					}
				}


			}
			break;
		}

		case State.ADD_ENDPOINT:
		case State.ADD_WAYPOINT: {
			break;
		}
	}

	
}


function onClickConnection(connection) {
	$("#form-marker").hide();
	$("#form-connection").show();

	$(".connection-id1").text(connection.id1);
	$(".connection-id2").text(connection.id2);

	$(".remove-connection").off('click');


	$(".remove-connection").on('click', function(e){
		connection.remove();
		$("#form-connection").hide();
	});



}

function editMarker(marker) {
	$("#form-marker").show();
	$("#form-connection").hide();

	$(".marker-type").text(marker.type == PointType.WAYPOINT ? "WAYPOINT" : "ENDPOINT");
	$(".marker-id").val(marker.id);
	$(".marker-pos-x").val(marker.x);
	$(".marker-pos-y").val(marker.y);
	$(".marker-room").val(marker.room);
	$(".marker-neighboors").text(marker.neighbors.join(", "));
	$(".marker-floor").text(marker.floor);

	$(".save-marker").off('click');
	$(".remove-marker").off('click');

	$(".save-marker").on('click', function(e) {

		var id = $(".marker-id").val();


		var res = markers.find(function(m){
			return (m.id == id && m != marker);
		});

		if (res !== undefined) {
			alert('ID must be unique');
		} else {
			marker.update(
				$(".marker-id").val(),
				$(".marker-pos-x").val(),
				$(".marker-pos-y").val(),
				$(".marker-room").val(),
				$(".marker-neighboors").val()
			);

			marker.resetConnections();
		}
	});

	$(".remove-marker").on('click', function(e){
		marker.remove();
		$("#form-marker").hide();
		remove(markers, marker);
	})
}

// Models
class MarkerPoint {
	constructor(mul, x, y, type, id, room, neighbors, floor) {
		this.mul = mul;
		this.id = id;
		this.x = x;
		this.y = y;
		this.type = type;
		this.room = room;

		if (neighbors != null && neighbors.length > 0) {
			this.neighbors = neighbors.split(" ");
		} else {
			this.neighbors = [];
		}

		
		this.floor = floor;
		this.connections = [];
	}

	select() {
		this._marker.setIcon(selectIcon);
	}

	unselect() {
		this.updateIcon();
	}

	resetConnections() {
		console.log("Reset connection neighbors", this.neighbors, 'Marker ID:', this.id);

		var self = this;
		this.removeConnections();

		this.neighbors.forEach(function(neighbor){
			self.connect(neighbor);

			var marker = findMarkerById(neighbor);
			if (marker != null) {
				marker.resetConnection(self.id);
			}
		});
	}

	resetConnection(marker2Id) {
		var connection = this.connections.find(function(con){
			return con.isConnected(marker2Id);
		});

		if (connection !== undefined && connection != null) {
			connection.disconnect();
			connection.connect(marker2Id);
		}

	}

	joinNeighbors() {
		console.log('[Join] Current neighbors:',this.neighbors, 'Marker ID:', this.id);

		if (this.neighbors == null || this.neighbors == undefined) {
			return "";
		}

		return this.neighbors.join(" ");
	}

	toLatLng() {
		return L.latLng(this.y/this.mul, this.x/this.mul);
	}

	hasId() {
		return (this.id !== undefined && this.id.length > 0);
	}

	remove() {
		var self = this;
		map.removeLayer(this._marker);


		this.connections.forEach(function(con){
			con.remove();
		});

		this.neighbors.forEach(function(neighbor){
			var marker = findMarkerById(neighbor);
			if (marker != null) {
				marker.removeConnection(self.id);
			}
		});



	}

	addToMap() {
		var self = this;

		var marker = L.marker(
	      this.toLatLng(), 
	      {
	      	icon: self.getIcon(),
	        draggable: true
	      }
	    );

	    marker.on('click', function(e){
	       onClickMarker(self);
	    });

	    marker.on('drag', function(e) {
	    	onStartDrag();
	      // console.log('marker drag event');
	    });
	    marker.on('dragstart', function(e) {
	      // map.off('click', mapClickListen);
	    });
	    marker.on('dragend', function(e) {
	      var point = e.target;

	      if (bounds.contains(point.getLatLng()) && state == State.CURSOR) {
		      var pos = imgPositionFromLatLng(point.getLatLng(), self.mul);
		      if (pos !== undefined) {
		      	self.x = pos.x;
		      	self.y = pos.y;
		      	console.log('point', self);

		      	self.resetConnections();
		  	  }
	  	  } else {
	  	  	 marker.setLatLng(self.toLatLng());
	  	  }
	    });

	    marker.addTo(map);

	    this._marker = marker;
	}

	updateIcon() {
		this._marker.setIcon(this.getIcon());
	}

	getIcon() {
		if (this.type == PointType.WAYPOINT) {
			return waypointIcon;
		} else {
			if (this.id !== undefined && this.id != null && typeof this.id == 'string' && (this.id.length == 3 || this.id.length == 4 || this.id.length == 6)) {
				return endpointIcon;
			} else {
				return incompleteIcon;
			}
		}
	}

	update(id, x,y,room, neighbors) {
		this.id = id;
		this.x = x;
		this.y = y;
		this.room = room;
		// this.neighbors = neighbors;

		this._marker.setLatLng(this.toLatLng());

		this.updateIcon();
	}

	connect(marker2Id) {
		console.log('[Marker][Connect] Connect with marker:', marker2Id, 'Marker ID:', this.id);

		var marker2 = findMarkerById(marker2Id);

		if (marker2 != null) {
			this.addNeighbor(marker2.id);
			marker2.addNeighbor(this.id);

			if (!marker2.isConnected(this.id) && !this.isConnected(marker2.id)) {
				var con = new Connection(this.id, marker2Id, this.floor);

				if (con.connect()) {
					this.connections.push(con);
					return true;
				} else {
					console.log('[Marker][Connect] Link connection failed', 'Marker ID:', this.id);
				}

				return false;
			} else {
				console.log('[Marker][Connect] One from items already connected', 'Marker ID:', this.id);
			}
		} else {
			console.log('[Marker][Connect] Marker2 is null', 'Marker ID:', this.id);
		}

		return false;
	}

	removeConnections() {
		this.connections.forEach(function(con){
			con.disconnect();
		});
		this.connections = [];
	}

	removeConnection(marker2Id) {
		var connection = this.connections.find(function(con){
			return con.isConnected(marker2Id);
		});

		if (connection != undefined) {
			connection.remove();
			remove(this.connections, connection);
		}


	}	

	addNeighbor(neighbor) {
		console.log('[Add] Current neighbors:',this.neighbors, 'Marker ID:', this.id);

		if (neighbor !== undefined && typeof neighbor == 'string') {
			var neigh = this.neighbors.find(function(n){
				return n == neighbor; 
			})

			if (neigh !== undefined && neigh != null) {
				return false;
			} else {
				this.neighbors.push(neighbor);
				return true;
			}
		}

		return false;
	}


	removeNeighbor(neighbor) {
		if (neighbor !== undefined && typeof neighbor == 'string') {
			remove(this.neighbors, neighbor);
		}
	}

	isConnected(marker2Id) {
		var marker2 = findMarkerById(marker2Id);

		if (marker2 != null) {
			var connection = this.connections.find(function(con){
				return con.isConnected(marker2Id);
			});

			console.log('Found connection:',connection, 'Marker ID:', this.id);
			return (connection !== undefined && connection != null);
		}

		return false;
	}
}

class Connection {

	constructor(id1, id2, floor) {
		this.id1 = id1;
		this.id2 = id2;
		this.floor = floor;
		this.polyline = null;
	}

	isConnected(id) {
		console.log('Connection isConnected(',this.id1,',',this.id2,') == ', id);
		return this.id1 == id || this.id2 == id;
	}

	connect() {
		var self = this;
		var m1 = findMarkerById(this.id1);
		var m2 = findMarkerById(this.id2);

		if (m1 != m2 && m1 != null && m2 != null) {

			

			var latlngs = [
				[m1.toLatLng().lat, m1.toLatLng().lng],
				[m2.toLatLng().lat, m2.toLatLng().lng]	
			]

			console.log("[Connection][Connect] Succesful link connection", latlngs);

			this.polyline = L.polyline(latlngs, {color: 'green'}).addTo(map);

			this.polyline.on('click', function(e) {
				onClickConnection(self);
			});

			return true;
		}

		console.log("[Connection][Connect] Failed link connection",m1,m2);

		return false;
	}

	disconnect() {
		console.log("[Connection][Disconnect] Disconnect",this.polyline);
		if (this.polyline != null) {
			map.removeLayer(this.polyline);
		}
		this.polyline = null;
	}

	remove() {
		var m1 = findMarkerById(this.id1);
		var m2 = findMarkerById(this.id2);

		if (m1 != null) {
			m1.removeNeighbor(this.id2);
		}

		if (m2 != null) {
			m2.removeNeighbor(this.id1);
		}

		this.disconnect();
	}

}


// Utils
function findMarkerById(id) {
	// console.log("Find marker by id", id, typeof id);
	marker = markers.find(function(marker){
		return (marker.id !== undefined 
			&& id !== undefined 
			&& typeof id == 'string'
			&& typeof marker.id == 'string'
			&& marker.id != ""
			&& id != ""
			&& (id.toUpperCase() == marker.id.toUpperCase())
		);
	});

	if (marker !== undefined && marker !== null) {
		return marker;
	} 
	return null;
}

function remove(arr, item) {
      for(var i = arr.length; i--;) {
          if(arr[i] === item) {
              arr.splice(i, 1);
          }
      }
  }

function imgPositionFromLatLng(latlng, mul) {

  if (bounds.contains(latlng)) {
  	
  	 y = (latlng.lat * mul).toFixed(0);
  	 x = (latlng.lng * mul).toFixed(0);

	 return L.point(x,y);
  }

}


// Import/Export JSON
$(".generate-json").on('click', function(e){
	var dict = [];

	markers.forEach(function(marker){
		dict.push({
			'id': marker.id,
			'posX': parseFloat(marker.x),
			'posY': parseFloat(2000-marker.y),
			'neighbors': marker.joinNeighbors(),
			'room': parseInt(marker.room),
			'type': (marker.type == PointType.WAYPOINT ? "waypoint" : "endpoint"),
			'floor': parseInt(marker.floor)
		});
	});

	$(".json-output").val(JSON.stringify(dict))

});
// [{"id":"1","posX":"512","posY":"1573","neighbors":"3","room":"2","type":"waypoint"}]
$(".load-json").on('click', function(e){
	console.log($(".json-output").val());
	var json = JSON.parse($(".json-output").val());


	if (json !== undefined) {
		markers = [];

		json.forEach(function(item){
			console.log(item);
			marker = new MarkerPoint(
				4, 
				item.posX, 
				2000-item.posY, 
				(item.type == 'waypoint' ? PointType.WAYPOINT : PointType.ENDPOINT),
				item.id, 
				item.room, 
				item.neighbors, 
				item.floor
			);

			marker.addToMap();
			markers.push(marker);


			marker.resetConnections();

		});
		// constructor(mul, x, y, type, id, room, neighbors

	} else {
		alert("Error in parsing json");
	}

});
