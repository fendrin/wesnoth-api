----
-- Copyright (C) 2020 by Fabian Mueller <fendrin@gmx.de>
-- SPDX-License-Identifier: GPL-2.0+

love  = love
fs    = love.filesystem
color = require"utils.log.ansicolors"

log_color =
    error: color.red
    warn:  color.yellow
    info:  color.green
    debug: color.blue

log_file  = "log.txt"
log_dir = fs.getSaveDirectory!

apply_color = (str, severity) -> return log_color[severity] .. str .. color.reset
msg = (txt, severity) ->
    date = os.date("*t", os.time!)
    with date
        date  = "[#{.hour}:#{.min}:#{.sec}]"
    output = "#{date} #{txt}"
    -- log to file
    success, errormsg = fs.append(
        log_file, "#{output}\n")
    unless success
        print(apply_color("Could not append to Logfile: #{errormsg}", "warn"))
    -- log to stdout
    print(apply_color(output, severity))


-- todo implement this stub
trace = (cfg) ->
    return (txt) ->
        msg(txt)


config = {}
set_config = (cfg) ->
    config = cfg


format_output = (severity, topic, txt) -> "(#{severity}) [#{topic}] #{txt}"
log = (topic, severity) ->
    return (txt) ->
        if severity == "debug"
            unless config[topic]
                if config.logger
                    output = format_output("debug", "logger", "domain [#{topic}] disabled")
                    msg(output, "debug")
                return
        output = format_output(severity, topic, txt)
        msg(output, severity)


header = "Wesnoth for Love log file\n"
success, errormsg = fs.write(log_file, header)
unless success
    print "couldn't write log file: #{errormsg}"
else
    logger = log("logger", "info")
    logger("Log File created at #{log_dir}/#{log_file}")

logging = (topic) -> {
    error: log(topic, "error")
    debug: log(topic, "debug")
    warn:  log(topic, "warn")
    info:  log(topic, "info")
    trace: trace(topic)
    :set_config
}

return logging

