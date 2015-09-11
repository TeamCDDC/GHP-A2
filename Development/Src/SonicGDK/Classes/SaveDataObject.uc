//================================================================================
//                  3D Sonic Games Development Kit (SonicGDK)
//                          by  Javier "Xaklse" Osset
//
//  Read SGDKGameInfo.uc file for details about permission to use this software.
//================================================================================
// Save Data Object > JsonObject > Object
//
// This class manages persistent data which can be saved to/loaded from a file.
//================================================================================
class SaveDataObject extends JsonObject;


/**Holds saved/loaded data.*/ var protected string Data;


/**
 * Gets the data stored in the data tree.
 * @return  first node of the data tree
 */
function JsonObject GetData()
{
    SetObject("data",DecodeJson(Data));

    return GetObject("data");
}

/**
 * Stores data in the data tree.
 * @param Json  data to insert
 */
function InsertData(JsonObject Json)
{
    Data = EncodeJson(Json);
}

/**
 * Loads the data stored in a file.
 * @param FileName  name of file to load data from
 * @return          true if the data of the file is loaded successfully
 */
function bool LoadData(string FileName)
{
    local JsonObject Json;

    if (class'Engine'.static.BasicLoadObject(self,"..\\UserData\\" $ FileName $ ".bin",true,0))
        return true;
    else
    {
        SetObject("data",new class'JsonObject');

        Json = GetObject("data");
        Json.SetStringValue("FileName",FileName);
        InsertData(Json);

        return false;
    }
}

/**
 * Saves the data in a file.
 * @param FileName  name of file to save data to
 * @return          true if the data is saved successfully
 */
function bool SaveData(optional string FileName)
{
    local JsonObject Json;

    if (FileName == "")
        FileName = GetData().GetStringValue("FileName");
    else
    {
        Json = GetData();

        if (Json.GetStringValue("FileName") != FileName)
        {
            Json.SetStringValue("FileName",FileName);
            InsertData(Json);
        }
    }

    return class'Engine'.static.BasicSaveObject(self,"..\\UserData\\" $ FileName $ ".bin",true,0,true);
}


defaultproperties
{
}
