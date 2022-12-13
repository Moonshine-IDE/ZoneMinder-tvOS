package views.modules.AllowedTVs.AllowedTVsVO
{
    import org.apache.royale.collections.ArrayList;

    [Bindable]
	public class AllowedTVsVO  
	{
	    public var DominoUniversalID:String;

	    private var _ID:String;
public function get ID():String
{
	return _ID;
}
public function set ID(value:String):void
{
	_ID = value;
}

private var _tvName:String;
public function get tvName():String
{
	return _tvName;
}
public function set tvName(value:String):void
{
	_tvName = value;
}

private var _availableCameras:ArrayList = new ArrayList();
public function get availableCameras():ArrayList
{
	return _availableCameras;
}
public function set availableCameras(value:ArrayList):void
{
	_availableCameras = value;
}



		public function AllowedTVsVO()
		{
		}
		
		public function toRequestObject():Object
		{
			var tmpRequestObject:Object = {
	
ID: this.ID,
tvName: this.tvName,
availableCameras: this.availableCameras ? JSON.stringify(availableCameras.source) : "[]"
};
if (DominoUniversalID) tmpRequestObject.DominoUniversalID = DominoUniversalID;
return tmpRequestObject;
		}

		public static function getAllowedTVsVO(value:Object):AllowedTVsVO
        {
            var tmpVO:AllowedTVsVO = new AllowedTVsVO();
            if ("ID" in value){	tmpVO.ID = value.ID;	}
if ("tvName" in value){	tmpVO.tvName = value.tvName;	}
if ("availableCameras" in value){	tmpVO.availableCameras = new ArrayList(value.availableCameras);	}
if ("DominoUniversalID" in value){	tmpVO.DominoUniversalID = value.DominoUniversalID;	}

            return tmpVO;
        }

        public static function getToRequestMultivalueDateString(value:ArrayList):String
        {
            var dates:Array = [];
            for (var i:int; i < value.length; i++)
            {
                dates.push(getToRequestDateString(value.getItemAt(i) as Date));
            }

			return ((dates.length > 0) ? JSON.stringify(dates) : "[]");
        }

        public static function getToRequestDateString(value:Date):String
        {
            var dateString:String = value.toISOString();
            return dateString;
        }

        public static function parseFromRequestMultivalueDateString(value:Array):ArrayList
        {
            var dates:ArrayList = new ArrayList();
            for (var i:int; i < value.length; i++)
            {
                dates.addItem(parseFromRequestDateString(value[i]));
            }

            return dates;
        }

        public static function parseFromRequestDateString(value:String):Date
        {
            return (new Date(value));
        }
	}
}