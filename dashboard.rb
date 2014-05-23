require './log_entry.rb'
require './visitor.rb'
require './period_visitor.rb'

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
            var subject_data = event.data.value || event.data.productId;
            productIds[subject_data] = event.subject  
          }
        };

        for (var i = events.length - 1; i >= 0; i--) {
          event = events[i];
          var subject = event.subject;

          if (event.type == 'action') {
            var subject_data = event.data.value || event.data.productId;
            if (typeof(subject_data) == 'string') {
              boughtProducts = [subject_data];
            } else {
              boughtProducts = subject_data;
            }

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

    LogEntry.map_reduce(mapToVisitor, reduceToVisitor).out(replace: "visitors").count
    Visitor.map_reduce(map, reduce).out(replace: 'reports').finalize(finalize).count

  end

  def run_by_period
    group_by_visitor_and_period
  end

  def group_by_visitor_and_period
    mapToVisitor = %Q{
      function(){
        var ts = this._id.getTimestamp(); 
        var month =  (ts.getUTCMonth() + 1) + "-" + ts.getUTCFullYear(); 

        emit(this.visitor_id, { created_at: this.created_at, type: this.type, data: this.data, subject: this.subject, month: month })
      }    
    }

    reduceToVisitor = %Q{
      function(vId, events) {
        return { visitor_id: vId, events: events};
      }      
    }

    map = %Q{
      function() {
        var productIds = {};
        var events = this.value.events;
        if (events == undefined) {
          emit({subject: this.value.subject, 'month': this.value.month}, {'view':1, 'action': 0, 'click': 0, 'month': ''});
          return;
        }

        for (var i = events.length - 1; i >= 0; i--) {
          var event = events[i]


          if (event.type == 'click') {
            var subject_data = event.data.value || event.data.productId;
            productIds[subject_data] = event.subject  
          }
        };

        for (var i = events.length - 1; i >= 0; i--) {


          event = events[i];
          var subject = event.subject;

          if (event.type == 'action') {
            var subject_data = event.data.value || event.data.productId;
            var subject_data_type = typeof(subject_data);

            if (subject_data_type == 'string') {
              boughtProducts = [subject_data];
            } else {
              boughtProducts = subject_data;
            }

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
    }

    reduce = %Q{
      function(subject, events) {
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
    }

    finalize = %Q{
      function(subject, reducedVal) {
          reducedVal.ctr = reducedVal.click / reducedVal.view ;
          reducedVal.conversion = reducedVal.action / reducedVal.click ;
          return reducedVal;
      }      
    }

    LogEntry.map_reduce(mapToVisitor, reduceToVisitor).out(replace: "period_visitors").count
    PeriodVisitor.map_reduce(map, reduce).out(replace: 'period_reports').finalize(finalize).count    
  end

end