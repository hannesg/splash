module Splash
  module Application
    class << self
      def respond(request)
        
  
        
      end
      
      
      def call(env)
        t='<form action="" method="post">
    <p>
      <input id="openid_identifier" name="openid[identifier][id]" type="text" />
    </p>

    <p>
      <input name="commit" type="submit" value="Sign in" />
    </p>
  </form>'
        request=Rack::Request.new(env)
        if resp = env["rack.openid.response"]
          if resp.status == :missing
            return [401, {"WWW-Authenticate" => "OpenID identifier=\"#{request["openid_identifier"]}\""}, []]
          else
            env["rack.session"]["user"]=resp.identity_url
            return [200,{'Content-Type' => 'text/html'},'<html>Welcome!<pre>'+(env.to_yaml)+'</pre></html>']
          end
        elsif request["openid_identifier"]
          return [401, {"WWW-Authenticate" => "OpenID identifier=\"#{request["openid_identifier"]}\""}, []]
        end
        return [200,{'Content-Type' => 'text/html'},'<html>'+t+'<pre>'+(request.to_yaml)+'</pre></html>']
      end
    end
  end
end