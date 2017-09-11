-- lua-resty-openidc options
opts = {
  redirect_uri_path = "/redirect_uri",
  discovery = "",
  client_id = "",
  client_secret = "",
  scope = "openid email profile",
  iat_slack = 600,
  redirect_uri_scheme = "https",
  logout_path = "/logout",
  redirect_after_logout_uri = "",
  refresh_session_interval = 900
}
