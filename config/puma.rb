pidfile File.expand_path(File.join(File.dirname(__FILE__), "../tmp/puma.pid"))
state_path File.expand_path(File.join(File.dirname(__FILE__), "../tmp/puma_state"))
workers 8
activate_control_app
