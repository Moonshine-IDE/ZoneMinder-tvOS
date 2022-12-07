package views.modules.Camera.CameraServices
{
	import classes.vo.Constants;
	import org.apache.royale.net.HTTPService;
	import org.apache.royale.net.beads.CORSCredentialsBead;
	import org.apache.royale.net.events.FaultEvent;
    import org.apache.royale.jewel.Snackbar;
	
	public class CameraServices
	{
		public static const LISTING_AGENT:String = "/CameraRead?OpenAgent";
		public static const ADD_AGENT:String = "/CameraCreate?OpenAgent";
		public static const EDIT_AGENT:String = "/CameraUpdate?OpenAgent";
		public static const REMOVE_AGENT:String = "/CameraDelete?OpenAgent";
		
		public function CameraServices()
		{
		}
		
		public function getCameraList(resultCallback:Function, faultCallback:Function=null):void
		{
			if (faultCallback == null)
			{
				faultCallback = onFault;
			}
			
			var service:HTTPService = new HTTPService();
			service.addBead(new CORSCredentialsBead(true));
			service.url = Constants.AGENT_BASE_URL + LISTING_AGENT;
			service.method = "GET";
			service.addEventListener("complete", resultCallback);
			service.addEventListener("ioError", faultCallback);
			service.send();
		}
		
		public function addNewCamera(submitObject:Object, resultCallback:Function, faultCallback:Function=null):void 
		{
			if (faultCallback == null)
			{
				faultCallback = onFault;
			}
			
			var urlParams:URLSearchParams = new URLSearchParams();
			for (var property:String in submitObject) 
			{
				urlParams.set(property, submitObject[property]);
			}
			
			var service:HTTPService = new HTTPService();
			service.addBead(new CORSCredentialsBead(true));
			service.url = Constants.AGENT_BASE_URL + ADD_AGENT;
			service.contentData = urlParams;
			service.method = "POST";
			service.addEventListener("complete", resultCallback);
			service.addEventListener("ioError", faultCallback);
			service.send();
		}

		public function updateCamera(submitObject:Object, resultCallback:Function, faultCallback:Function=null):void
        {
            if (faultCallback == null)
            {
                faultCallback = onFault;
            }

            var urlParams:URLSearchParams = new URLSearchParams();
            for (var property:String in submitObject)
            {
                urlParams.set(property, submitObject[property]);
            }

            var service:HTTPService = new HTTPService();
            service.addBead(new CORSCredentialsBead(true));
            service.url = Constants.AGENT_BASE_URL + EDIT_AGENT;
            service.contentData = urlParams;
            service.method = "POST";
            service.addEventListener("complete", resultCallback);
            service.addEventListener("ioError", faultCallback);
            service.send();
        }

		public function removeCamera(submitObject:Object, resultCallback:Function, faultCallback:Function=null):void
        {
            if (faultCallback == null)
            {
                faultCallback = onFault;
            }

            var urlParams:URLSearchParams = new URLSearchParams();
            for (var property:String in submitObject)
            {
                urlParams.set(property, submitObject[property]);
            }

            var service:HTTPService = new HTTPService();
            service.addBead(new CORSCredentialsBead(true));
            service.url = Constants.AGENT_BASE_URL + REMOVE_AGENT;
            service.contentData = urlParams;
            service.method = "POST";
            service.addEventListener("complete", resultCallback);
            service.addEventListener("ioError", faultCallback);
            service.send();
        }
		
		public function onFault(event:FaultEvent):void 
		{
			Snackbar.show(event.message.toLocaleString(), 4000, null);
		}
	}
}