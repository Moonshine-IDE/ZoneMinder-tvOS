package views.modules.AllowedTVs.AllowedTVsServices
{
    import org.apache.royale.collections.ArrayList;
    import org.apache.royale.events.EventDispatcher;
    import classes.vo.Constants;
    import org.apache.royale.jewel.Snackbar;
	import org.apache.royale.net.events.FaultEvent;
	import classes.events.ErrorEvent;
	import classes.utils.Utils;
    import views.modules.AllowedTVs.AllowedTVsServices.AllowedTVsServices;
import views.modules.AllowedTVs.AllowedTVsVO.AllowedTVsVO;

	public class AllowedTVsProxy extends EventDispatcher
	{
	    public static const EVENT_ITEM_UPDATED:String = "eventItemUpdated";
        public static const EVENT_ITEM_REMOVED:String = "eventItemRemoved";
        public static const EVENT_ITEM_SELECTED:String = "eventItemSelected";

		private var serviceDelegate:AllowedTVsServices = new AllowedTVsServices();
		private var lastEditingIndex:int = -1;
		private var lastEditingItem:AllowedTVsVO;
		
		private static var _instance:AllowedTVsProxy;
        public static function getInstance():AllowedTVsProxy
        {
            if (!_instance)
            {
                _instance = new AllowedTVsProxy();
            }
            return _instance;
        }
        
        public function AllowedTVsProxy()
        {
            if (_instance != null) 
            {
                throw new Error("New Instances Not Possible.", "AllowedTVsProxy");
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
        
        private var _selectedItem:AllowedTVsVO;
        public function get selectedItem():AllowedTVsVO
        {
            return _selectedItem;
        }
        public function set selectedItem(value:AllowedTVsVO):void
        {
            _selectedItem = value;
        }

        public function requestItems():void
        {
            if (Constants.AGENT_BASE_URL)
            {
                Utils.setBusy();
                this.serviceDelegate.getAllowedTVsList(onAllowedTVsListLoaded, onAllowedTVsListLoadFailed);
            }
        }
        
        public function submitItem(value:AllowedTVsVO):void
        {
            // simple in-memory add/update for now
            if (selectedItem != null)
            {
                if (Constants.AGENT_BASE_URL)
            	{
            		lastEditingIndex = items.getItemIndex(selectedItem);
            		lastEditingItem = value;
            		Utils.setBusy();
            		this.serviceDelegate.updateAllowedTVs(value.toRequestObject(), onAllowedTVsUpdated, onAllowedTVsUpdateFailed);
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
            		this.serviceDelegate.addNewAllowedTVs(value.toRequestObject(), onAllowedTVsCreated, onAllowedTVsCreationFailed);
            	}
            	else
            	{
            		items.addItem(value);
            		this.dispatchEvent(new Event(EVENT_ITEM_UPDATED));
            	}
            }
        }
        
        public function removeItem(value:AllowedTVsVO):void
        {
            if (Constants.AGENT_BASE_URL)
            {
                selectedItem = value;
                Utils.setBusy();
                this.serviceDelegate.removeAllowedTVs(
                    {DominoUniversalID: value.DominoUniversalID},
                    onAllowedTVsRemoved,
                    onAllowedTVsRemoveFailed
                );
            }
            else
            {
                items.removeItem(value);
                this.dispatchEvent(new Event(EVENT_ITEM_UPDATED));
            }
        }

        private function onAllowedTVsListLoaded(event:Event):void
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
                            var item:AllowedTVsVO = new AllowedTVsVO();
                            items.addItem(
                                AllowedTVsVO.getAllowedTVsVO(json.documents[i])
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
                Snackbar.show("Loading lists of new AllowedTVs failed!", 8000, null);
            }
        }

        private function onAllowedTVsListLoadFailed(event:FaultEvent):void
        {
            Utils.removeBusy();
            Snackbar.show("Loading lists of new AllowedTVs failed!\n"+ event.message.toLocaleString(), 8000, null);
        }
        
        private function onAllowedTVsCreated(event:Event):void
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
                            AllowedTVsVO.getAllowedTVsVO(json.document)
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
				Snackbar.show("Creation of new AllowedTVs failed!", 8000, null);
			}
		}
		
		private function onAllowedTVsCreationFailed(event:FaultEvent):void
		{
			Utils.removeBusy();
			this.dispatchEvent(
                new ErrorEvent(
                    ErrorEvent.SERVER_ERROR,
                    "Creation of new AllowedTVs failed!\n"+ event.message.toLocaleString()
                )
            );
		}

		private function onAllowedTVsUpdated(event:Event):void
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
                Snackbar.show("Update of new AllowedTVs failed!", 8000, null);
            }
        }

        private function onAllowedTVsUpdateFailed(event:FaultEvent):void
        {
            Utils.removeBusy();
            this.dispatchEvent(
                new ErrorEvent(
                    ErrorEvent.SERVER_ERROR,
                    "Update of AllowedTVs failed!\n"+ event.message.toLocaleString()
                )
            );
        }

		private function onAllowedTVsRemoved(event:Event):void
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
                Snackbar.show("Deletion of AllowedTVs failed!", 8000, null);
            }
        }

        private function onAllowedTVsRemoveFailed(event:FaultEvent):void
        {
            Utils.removeBusy();
            this.dispatchEvent(
                new ErrorEvent(
                    ErrorEvent.SERVER_ERROR,
                    "Removal of AllowedTVs failed!\n"+ event.message.toLocaleString()
                )
            );
        }
	}
}