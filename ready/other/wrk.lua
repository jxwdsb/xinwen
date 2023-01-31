	
wrk.method = "POST"
wrk.body   = "userID=1&token=eyJ0b2tlbiI6IjEyMyIsInRpbWUiOjE2NjA0MTk1Mzd9"
wrk.headers["Content-Type"] = "application/x-www-form-urlencoded"
--[[
wrk -t256 -c65535 -d30s -s /root/1.lua https://api.jybeing.com/byhd/hdb/user_token_update.php
]]