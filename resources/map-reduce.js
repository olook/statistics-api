/**
  * Javascript for map-reducing and analyze our events log collection
  *
  */

 /* 
  * The log event collection seens like this

	{ visitor_id: 123,
	 created_at: 2014-04-01,
	 event_type: 'view',
	 subject: 'fb_mais' };

	{
	 visitor_id: 123,
	 created_at: 2014-04-01,
	 event_type: 'click',
	 data: {productId: 1001},
	 subject: 'fb_mais' 
	}

	{
	 visitor_id: 123,
	 created_at: 2014-04-01,
	 event_type: 'action',
	 data: {productId: [1001, 1002]},
	}


 * So, the first step is to agreggate these log entries into visitors: 
 *
 **/

var mapToVisitor = function(){
  emit(this.visitor_id, { created_at: this.created_at, type: this.type, data: this.data, subject: this.subject })
}

var reduceToVisitor = function(vId, events) {
  return { visitor_id: vId, events: events};
}

db.log_entries.mapReduce(mapToVisitor, reduceToVisitor, {out: 'visitors'});
db.visitors.find();

/**
  * This, will create a collection like the following
  *

  {
	visitor_id: i+1,
	events: [
		{type: 'view', created_at: new Date(), subject: 'fb_mais'},
		{type: 'click', created_at: new Date(), subject: 'fb_mais', data: {product_id: 1001}},
		{type: 'action', created_at: new Date(), data: {product_id: [1001, 1002]}},
	]
  }

  *
  * Now, we apply a new map-reduce process to calculate the CTR and Conversion of each Subject:
  */

map = function() {
	var productIds = {};
	var events = this.value.events;
	if (events == undefined) {
		emit(this.value.subject, {'view':1, 'action': 0, 'click': 0});
		return;
	}

	for (var i = events.length - 1; i >= 0; i--) {
		event = events[i]
		if (event.type == 'click') {
			productIds[event.data.productId] = event.subject	
		}
	};

	for (var i = events.length - 1; i >= 0; i--) {
		event = events[i];
		var subject = event.subject;

		if (event.type == 'action') {
			boughtProducts = event.data.productId;

			var has=false;

			for (var j = boughtProducts.length - 1; j >= 0; j--) {
				id = boughtProducts[j]
				subject = productIds[id];
				has = subject != undefined;
				if (has) break;
			}

			if (!has) {
				continue;
			}
		}

		var v=a=c=0;

    if (event.type == 'view') v=1;
    if (event.type == 'action') a=1;
    if (event.type == 'click') c=1;
		
		emit(subject, {'view':v, 'action': a, 'click': c});
	}
}

reduce = function(subject, events) {
    reducedValues = {'action': 0, 'click': 0, 'view': 0};

    for (var i = events.length - 1; i >= 0; i--) {
        for (j in reducedValues) {
            reducedValues[j] = reducedValues[j] + events[i][j];
        }
    };

    return reducedValues;
}

finalize = function(subject, reducedVal) {
    reducedVal.ctr = reducedVal.click / reducedVal.view ;
    reducedVal.conversion = reducedVal.action / reducedVal.click ;
    return reducedVal;
}

db.visitors.mapReduce(map, reduce, {out: 'reports', finalize: finalize});
db.reports.find();  

