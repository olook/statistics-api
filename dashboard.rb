require './log_entry.rb'
require './visitor.rb'

class Dashboard

  def run
    group_by_visitor
  end

  def group_by_visitor
    mapToVisitor = <<EOF
      function(){
        emit(this.visitor_id, { created_at: this.created_at, type: this.type, data: this.data, subject: this.subject })
      }
EOF

    reduceToVisitor = <<EOF
      function(vId, events) {
        return { visitor_id: vId, events: events};
      }
EOF

    map = %Q{
      function() {
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
    }

    reduce = %Q{
      function(subject, events) {
          reducedValues = {'action': 0, 'click': 0, 'view': 0};

          for (var i = events.length - 1; i >= 0; i--) {
              for (j in reducedValues) {
                  reducedValues[j] = reducedValues[j] + events[i][j];
              }
          };

          return reducedValues;
      }
    }

    finalize = %Q{
      function(subject, reducedVal) {
          reducedVal.ctr = reducedVal.click / reducedVal.view ;
          reducedVal.conversion = reducedVal.action / reducedVal.click ;
          return reducedVal;
      }            
    }

    r = LogEntry.map_reduce(mapToVisitor, reduceToVisitor).out(replace: "visitors")
    puts "counts: #{r.counts}"

    r = Visitor.map_reduce(map, reduce).out(replace: 'result').finalize(finalize)
    puts "counts: #{r.counts}"
    r
  end 

end