-- lua-resty-openidc options

-- Gets values from credstash
local function cs_get(key)
	local f = io.popen("credstash get "..key)
	r = f:read()
	f:close()
	return r
end

opts = {
  redirect_uri_path = "/redirect_uri",
  discovery = cs_get("accessproxy.discovery_url"),
  client_id = cs_get("accessproxy.client_id"),
  client_secret = cs_get("accessproxy.client_secret"),
  scope = "openid email profile",
  iat_slack = 600,
  redirect_uri_scheme = "https",
  logout_path = "/logout",
  redirect_after_logout_uri = "https://sso.mozilla.com/",
  refresh_session_interval = 900
}
