-- Lua reference for nginx: https://github.com/openresty/lua-nginx-module
-- Lua reference for openidc: https://github.com/pingidentity/lua-resty-openidc
local oidc = require("resty.openidc")
local cjson = require( "cjson" )

if not opts then
  ngx.log(ngx.ERR, "no configuration found")
end

-- Authenticate with lua-resty-openidc if necessary (this will return quickly if no authentication is necessary)
local res, err, url, session = oidc.authenticate(opts)

-- Check if authentication succeeded, otherwise kick the user out
if err then
  if session ~= nil then
    session:destroy()
  end
  ngx.redirect(opts.logout_path)
end
-- If you want all claims as headers, use this
-- local function build_headers(t, name)
--   for k,v in pairs(t) do
--     -- unpack tables
--     if type(v) == "table" then
--       local j = cjson.encode(v)
--       ngx.req.set_header("OIDC_CLAIM_"..name..k, j)
--     else
--       ngx.req.set_header("OIDC_CLAIM_"..name..k, tostring(v))
--     end
--   end
-- end

-- build_headers(session.data.id_token, "ID_TOKEN_")
-- build_headers(session.data.user, "USER_PROFILE_")

-- Set most useful headers with user info and OIDC claims for the underlaying web application to use
-- These header names are voluntarily similar to Apaches mod_auth_openidc and other modules,
-- but may of course be modified
ngx.req.set_header("REMOTE_USER", session.data.user.email)
ngx.req.set_header("X-Forwarded-User", session.data.user.email)
ngx.req.set_header("OIDC_CLAIM_ACCESS_TOKEN", session.data.access_token)
ngx.req.set_header("OIDC_CLAIM_ID_TOKEN", session.data.enc_id_token)
ngx.req.set_header("via",session.data.user.email)

-- Flatten groups for apps that won't read JSON
local gprs = ""
local usergrp = ""
if session.data.user.groups then
    usergrp = session.data.user.groups
else
    usergrp = session.data.user['https://sso.mozilla.com/claim/groups']
end
for k,v in pairs(usergrp) do
  grps = grps and grps.."|"..v or v
end
ngx.req.set_header("X-Forwarded-Groups", grps)

-- Access control: only allow specific users in (this is optional, without it all authenticated users are allowed in)
-- if not usergrp.ssh_allowed then
--   ngx.log(ngx.ERR, "Permission denied for user: "+session.data.user.user_id)
--   if session ~= nil then
--     session:destroy()
--   end
--   ngx.redirect(opts.logout_path)
-- end
