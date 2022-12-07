package views.modules.Camera.CameraVO
{
    import org.apache.royale.collections.ArrayList;

    [Bindable]
	public class CameraVO  
	{
	    public var DominoUniversalID:String;

	    private var _CameraID:String;
public function get CameraID():String
{
	return _CameraID;
}
public function set CameraID(value:String):void
{
	_CameraID = value;
}

private var _Name:String;
public function get Name():String
{
	return _Name;
}
public function set Name(value:String):void
{
	_Name = value;
}

private var _URL:String;
public function get URL():String
{
	return _URL;
}
public function set URL(value:String):void
{
	_URL = value;
}

private var _Frequency:String;
public function get Frequency():String
{
	return _Frequency;
}
public function set Frequency(value:String):void
{
	_Frequency = value;
}

private var _Group:String;
public function get Group():String
{
	return _Group;
}
public function set Group(value:String):void
{
	_Group = value;
}

private var _SubGroup:String;
public function get SubGroup():String
{
	return _SubGroup;
}
public function set SubGroup(value:String):void
{
	_SubGroup = value;
}

private var _AllowedTVs:ArrayList = new ArrayList();
public function get AllowedTVs():ArrayList
{
	return _AllowedTVs;
}
public function set AllowedTVs(value:ArrayList):void
{
	_AllowedTVs = value;
}



		public function CameraVO()
		{
		}
		
		public function toRequestObject():Object
		{
			var tmpRequestObject:Object = {
	
CameraID: this.CameraID,
Name: this.Name,
URL: this.URL,
Frequency: this.Frequency,
Group: this.Group,
SubGroup: this.SubGroup,
AllowedTVs: this.AllowedTVs ? JSON.stringify(AllowedTVs.source) : "[]"
};
if (DominoUniversalID) tmpRequestObject.DominoUniversalID = DominoUniversalID;
return tmpRequestObject;
		}

		public static function getCameraVO(value:Object):CameraVO
        {
            var tmpVO:CameraVO = new CameraVO();
            if ("CameraID" in value){	tmpVO.CameraID = value.CameraID;	}
if ("Name" in value){	tmpVO.Name = value.Name;	}
if ("URL" in value){	tmpVO.URL = value.URL;	}
if ("Frequency" in value){	tmpVO.Frequency = value.Frequency;	}
if ("Group" in value){	tmpVO.Group = value.Group;	}
if ("SubGroup" in value){	tmpVO.SubGroup = value.SubGroup;	}
if ("AllowedTVs" in value){	tmpVO.AllowedTVs = new ArrayList(value.AllowedTVs);	}
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