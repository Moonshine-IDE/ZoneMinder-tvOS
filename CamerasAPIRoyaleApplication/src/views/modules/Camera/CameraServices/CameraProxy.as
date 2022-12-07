package views.modules.Camera.CameraServices
{
    import org.apache.royale.collections.ArrayList;
    import org.apache.royale.events.EventDispatcher;
    import classes.vo.Constants;
    import org.apache.royale.jewel.Snackbar;
	import org.apache.royale.net.events.FaultEvent;
	import classes.events.ErrorEvent;
	import classes.utils.Utils;
    import views.modules.Camera.CameraServices.CameraServices;
import views.modules.Camera.CameraVO.CameraVO;

	public class CameraProxy extends EventDispatcher
	{
	    public static const EVENT_ITEM_UPDATED:String = "eventItemUpdated";
        public static const EVENT_ITEM_REMOVED:String = "eventItemRemoved";
        public static const EVENT_ITEM_SELECTED:String = "eventItemSelected";

		private var serviceDelegate:CameraServices = new CameraServices();
		private var lastEditingIndex:int = -1;
		private var lastEditingItem:CameraVO;
		
		private static var _instance:CameraProxy;
        public static function getInstance():CameraProxy
        {
            if (!_instance)
            {
                _instance = new CameraProxy();
            }
            return _instance;
        }
        
        public function CameraProxy()
        {
            if (_instance != null) 
            {
                throw new Error("New Instances Not Possible.", "CameraProxy");
            }			
            else 
            {
                _instance = this;
            }
        }
        
        private var _items:ArrayList = new ArrayList();
        [Bindable]
        public function get items():ArrayList
        {
            return _items;
        }
        public function set items(value:ArrayList):void
        {
            _items = value;
        }
        
        private var _selectedItem:CameraVO;
        public function get selectedItem():CameraVO
        {
            return _selectedItem;
        }
        public function set selectedItem(value:CameraVO):void
        {
            _selectedItem = value;
        }

        public function requestItems():void
        {
            if (Constants.AGENT_BASE_URL)
            {
                Utils.setBusy();
                this.serviceDelegate.getCameraList(onCameraListLoaded, onCameraListLoadFailed);
            }
        }
        
        public function submitItem(value:CameraVO):void
        {
            // simple in-memory add/update for now
            if (selectedItem != null)
            {
                if (Constants.AGENT_BASE_URL)
            	{
            		lastEditingIndex = items.getItemIndex(selectedItem);
            		lastEditingItem = value;
            		Utils.setBusy();
            		this.serviceDelegate.updateCamera(value.toRequestObject(), onCameraUpdated, onCameraUpdateFailed);
            	}
            	else
            	{
            		items[items.getItemIndex(selectedItem)] = value;
            		this.dispatchEvent(new Event(EVENT_ITEM_UPDATED));
            	}
            }
            else
            {
                if (Constants.AGENT_BASE_URL)
            	{
            		Utils.setBusy();
            		this.serviceDelegate.addNewCamera(value.toRequestObject(), onCameraCreated, onCameraCreationFailed);
            	}
            	else
            	{
            		items.addItem(value);
            		this.dispatchEvent(new Event(EVENT_ITEM_UPDATED));
            	}
            }
        }
        
        public function removeItem(value:CameraVO):void
        {
            if (Constants.AGENT_BASE_URL)
            {
                selectedItem = value;
                Utils.setBusy();
                this.serviceDelegate.removeCamera(
                    {DominoUniversalID: value.DominoUniversalID},
                    onCameraRemoved,
                    onCameraRemoveFailed
                );
            }
            else
            {
                items.removeItem(value);
                this.dispatchEvent(new Event(EVENT_ITEM_UPDATED));
            }
        }

        private function onCameraListLoaded(event:Event):void
        {
            Utils.removeBusy();
            var fetchedData:String = event.target["data"];
            if (fetchedData)
            {
                var json:Object = JSON.parse(fetchedData as String);
                if (!json.errorMessage)
                {
                    if (("documents" in json) && (json.documents is Array))
                    {
                        items = new ArrayList();
                        for (var i:int=0; i < json.documents.length; i++)
                        {
                            var item:CameraVO = new CameraVO();
                            items.addItem(
                                CameraVO.getCameraVO(json.documents[i])
                            );
                        }
                        this.dispatchEvent(new Event(EVENT_ITEM_UPDATED));
                    }
                }
                else
                {
                    this.dispatchEvent(
                        new ErrorEvent(
                            ErrorEvent.SERVER_ERROR,
                            json.errorMessage,
                            ("validationErrors" in json) ? json.validationErrors : null
                        )
                    );
                }

                /*if (!sessionCheckProxy.checkUserSession(xmlData))
                {
                    return;
                }

                var errorMessage:String = xmlData["ErrorMessage"].toString();

                if (!errorMessage)
                {
                    if (xmlData[0].Results.affectedObject == null)
                    {
                        sendNotification(NOTE_DISK_CREATE_FAILED, "Failed to add Disk! Please, try later.");
                    }
                    else
                    {
                        manageVmBaseProxy.selectedVM.disksAC = new ArrayList();
                        ParseCentralVMs.parseVMDisks(xmlData[0].Results.affectedObject, manageVmBaseProxy.selectedVM.disksAC);

                        sendNotification(NOTE_DISK_CREATE_COMPLETED);
                    }
                }
                else
                {
                    sendNotification(NOTE_DISK_CREATE_FAILED, "Disk create request failed: " + errorMessage);
                }*/
            }
            else
            {
                Snackbar.show("Loading lists of new Camera failed!", 8000, null);
            }
        }

        private function onCameraListLoadFailed(event:FaultEvent):void
        {
            Utils.removeBusy();
            Snackbar.show("Loading lists of new Camera failed!\n"+ event.message.toLocaleString(), 8000, null);
        }
        
        private function onCameraCreated(event:Event):void
		{
			Utils.removeBusy();
			var fetchedData:String = event.target["data"];
			if (fetchedData)
			{
				var json:Object = JSON.parse(fetchedData as String);
                if (!json.errorMessage)
                {
                    if ("document" in json)
                    {
                        items.addItem(
                            CameraVO.getCameraVO(json.document)
                        );
                    }
                    this.dispatchEvent(new Event(EVENT_ITEM_UPDATED));
                }
                else
                {
                    this.dispatchEvent(
                        new ErrorEvent(
                            ErrorEvent.SERVER_ERROR,
                            json.errorMessage,
                            ("validationErrors" in json) ? json.validationErrors : null
                        )
                    );
                }

				/*if (!sessionCheckProxy.checkUserSession(xmlData))
				{
					return;
				}
				
				var errorMessage:String = xmlData["ErrorMessage"].toString();
				
				if (!errorMessage)
				{
					if (xmlData[0].Results.affectedObject == null)
					{
						sendNotification(NOTE_DISK_CREATE_FAILED, "Failed to add Disk! Please, try later.");
					}
					else
					{
						manageVmBaseProxy.selectedVM.disksAC = new ArrayList();
						ParseCentralVMs.parseVMDisks(xmlData[0].Results.affectedObject, manageVmBaseProxy.selectedVM.disksAC);
						
						sendNotification(NOTE_DISK_CREATE_COMPLETED);
					}
				}
				else
				{
					sendNotification(NOTE_DISK_CREATE_FAILED, "Disk create request failed: " + errorMessage);
				}*/
			}
			else
			{
				Snackbar.show("Creation of new Camera failed!", 8000, null);
			}
		}
		
		private function onCameraCreationFailed(event:FaultEvent):void
		{
			Utils.removeBusy();
			this.dispatchEvent(
                new ErrorEvent(
                    ErrorEvent.SERVER_ERROR,
                    "Creation of new Camera failed!\n"+ event.message.toLocaleString()
                )
            );
		}

		private function onCameraUpdated(event:Event):void
        {
            Utils.removeBusy();
            var fetchedData:String = event.target["data"];
            if (fetchedData)
            {
                var json:Object = JSON.parse(fetchedData as String);
                if (!json.errorMessage)
                {
                    items[lastEditingIndex] = lastEditingItem;
                    lastEditingItem = null;
                    lastEditingIndex = -1;
                    this.dispatchEvent(new Event(EVENT_ITEM_UPDATED));
                }
                else
                {
                    this.dispatchEvent(
                        new ErrorEvent(
                            ErrorEvent.SERVER_ERROR,
                            json.errorMessage,
                            ("validationErrors" in json) ? json.validationErrors : null
                        )
                    );
                }

                /*if (!sessionCheckProxy.checkUserSession(xmlData))
                {
                    return;
                }

                var errorMessage:String = xmlData["ErrorMessage"].toString();

                if (!errorMessage)
                {
                    if (xmlData[0].Results.affectedObject == null)
                    {
                        sendNotification(NOTE_DISK_CREATE_FAILED, "Failed to add Disk! Please, try later.");
                    }
                    else
                    {
                        manageVmBaseProxy.selectedVM.disksAC = new ArrayList();
                        ParseCentralVMs.parseVMDisks(xmlData[0].Results.affectedObject, manageVmBaseProxy.selectedVM.disksAC);

                        sendNotification(NOTE_DISK_CREATE_COMPLETED);
                    }
                }
                else
                {
                    sendNotification(NOTE_DISK_CREATE_FAILED, "Disk create request failed: " + errorMessage);
                }*/
            }
            else
            {
                Snackbar.show("Update of new Camera failed!", 8000, null);
            }
        }

        private function onCameraUpdateFailed(event:FaultEvent):void
        {
            Utils.removeBusy();
            this.dispatchEvent(
                new ErrorEvent(
                    ErrorEvent.SERVER_ERROR,
                    "Update of Camera failed!\n"+ event.message.toLocaleString()
                )
            );
        }

		private function onCameraRemoved(event:Event):void
        {
            Utils.removeBusy();
            var fetchedData:String = event.target["data"];
            if (fetchedData)
            {
                var json:Object = JSON.parse(fetchedData as String);
                if (!json.errorMessage)
                {
                    if (selectedItem)
                    {
                        items.removeItem(selectedItem);
                        selectedItem = null;
                        this.dispatchEvent(new Event(EVENT_ITEM_UPDATED));
                    }
                }
                else
                {
                    this.dispatchEvent(
                        new ErrorEvent(
                            ErrorEvent.SERVER_ERROR,
                            json.errorMessage,
                            ("validationErrors" in json) ? json.validationErrors : null
                        )
                    );
                }

                /*if (!sessionCheckProxy.checkUserSession(xmlData))
                {
                    return;
                }

                var errorMessage:String = xmlData["ErrorMessage"].toString();

                if (!errorMessage)
                {
                    if (xmlData[0].Results.affectedObject == null)
                    {
                        sendNotification(NOTE_DISK_CREATE_FAILED, "Failed to add Disk! Please, try later.");
                    }
                    else
                    {
                        manageVmBaseProxy.selectedVM.disksAC = new ArrayList();
                        ParseCentralVMs.parseVMDisks(xmlData[0].Results.affectedObject, manageVmBaseProxy.selectedVM.disksAC);

                        sendNotification(NOTE_DISK_CREATE_COMPLETED);
                    }
                }
                else
                {
                    sendNotification(NOTE_DISK_CREATE_FAILED, "Disk create request failed: " + errorMessage);
                }*/
            }
            else
            {
                Snackbar.show("Deletion of Camera failed!", 8000, null);
            }
        }

        private function onCameraRemoveFailed(event:FaultEvent):void
        {
            Utils.removeBusy();
            this.dispatchEvent(
                new ErrorEvent(
                    ErrorEvent.SERVER_ERROR,
                    "Removal of Camera failed!\n"+ event.message.toLocaleString()
                )
            );
        }
	}
}