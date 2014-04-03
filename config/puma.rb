pidfile File.expand_path(File.join(File.dirname(__FILE__), "../tmp/puma.pid"))
state_path File.expand_path(File.join(File.dirname(__FILE__), "../tmp/puma_state"))
workers 8
stdout_redirect File.expand_path(File.join(File.dirname(__FILE__), "../log/puma.log")), File.expand_path(File.join(File.dirname(__FILE__), "../log/puma_err.log"))
activate_control_app
