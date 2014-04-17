var mapToVisitor = function(){
  var ts = this._id.getTimestamp(); 
  var month =  (ts.getUTCMonth() + 1) + "-" + ts.getUTCFullYear(); 

  emit(this.visitor_id, { created_at: this.created_at, type: this.type, data: this.data, subject: this.subject, month: month })
}

var reduceToVisitor = function(vId, events) {
  return { visitor_id: vId, events: events};
}

db.log_entries.mapReduce(mapToVisitor, reduceToVisitor, {out: 'period_visitors'});
db.period_visitors.find();

var map = function() {
  var productIds = {};
  var events = this.value.events;
  if (events == undefined) {
    emit(this.value.subject, {'view':1, 'action': 0, 'click': 0, 'month': ''});
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
    emit({subject: subject, 'month': event.month}, {'view':v, 'action': a, 'click': c});
  }
}

var reduce = function(subject, events) {
    reducedValues = {'action': 0, 'click': 0, 'view': 0};
    for (var i = events.length - 1; i >= 0; i--) {
        for (j in reducedValues) {
            if(j!="month") {
              reducedValues[j] = reducedValues[j] + events[i][j];
            } else {

            }
        }
    };

    return reducedValues;
}

var finalize = function(subject, reducedVal) {
    reducedVal.ctr = reducedVal.click / reducedVal.view ;
    reducedVal.conversion = reducedVal.action / reducedVal.click ;
    return reducedVal;
}

db.period_visitors.mapReduce(map, reduce, {out: 'period_reports', finalize: finalize});
db.period_reports.find({'_id.month' : '4-2014'});  

