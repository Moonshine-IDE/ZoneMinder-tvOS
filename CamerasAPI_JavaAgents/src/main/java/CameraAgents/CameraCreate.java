package CameraAgents;

import java.util.ArrayList;
import java.util.Collection;

import com.moonshine.domino.crud.CreateAgentBase;
import com.moonshine.domino.field.FieldDefinition;
import com.moonshine.domino.field.FieldType;
import com.moonshine.domino.security.*;
import com.moonshine.domino.util.DominoUtils;
import com.moonshine.domino.util.ParameterException;

import lotus.domino.*;

public class CameraCreate extends CreateAgentBase {
	protected String getFormName() {
		return "Camera";
	}
	 

	protected Collection<FieldDefinition> getFieldList() {
		Collection<FieldDefinition> fields = new ArrayList<FieldDefinition>();
		fields.add(new FieldDefinition("CameraID", FieldType.TEXT, false));


		fields.add(new FieldDefinition("Name", FieldType.TEXT, false));


		fields.add(new FieldDefinition("URL", FieldType.TEXT, false));


		fields.add(new FieldDefinition("Frequency", FieldType.TEXT, false));


		fields.add(new FieldDefinition("Group", FieldType.TEXT, false));


		fields.add(new FieldDefinition("SubGroup", FieldType.TEXT, false));



		return fields;
	}
	

	protected Object getDocumentIdentifier() throws ParameterException {
		return null; // no uniqueness validation
		
		/* You can add uniqueness validation like this:
		Collection<FieldDefinition> keys = new ArrayList<FieldDefinition>();
		keys.add(new FieldDefinition("CameraID", FieldType.TEXT, false));


		return getKeyRequired(keys);
		*/
	}
	

	protected View getLookupView() throws NotesException {
		return null; // no uniqueness validation
		
		/* If uniqueness validation is desired:
		try {
			return DominoUtils.getView(agentDatabase, "Cameras");
		}
		catch (Exception ex) {
			getLog().err("Could not open lookup view: ", ex);
			return null;
		}
		*/
	}
	 

	@Override
	protected Collection<FieldDefinition> getReturnFieldList() {
		Collection<FieldDefinition> fields = new ArrayList<FieldDefinition>();
		fields.add(new FieldDefinition("CameraID", FieldType.TEXT, false));
		fields.add(new FieldDefinition("Name", FieldType.TEXT, false));
		fields.add(new FieldDefinition("URL", FieldType.TEXT, false));
		fields.add(new FieldDefinition("Frequency", FieldType.TEXT, false));
		fields.add(new FieldDefinition("Group", FieldType.TEXT, false));
		fields.add(new FieldDefinition("SubGroup", FieldType.TEXT, false));

		return fields;
		
	}
	

	protected void runAdditionalProcessing(Document document) {
		// nothing to do
	}
	
	protected SecurityInterface getSecurity() {
		return new AllowAllSecurity(session);
	}
	
	/**
	 * Cleanup any Domino API objects created by this agent
	 */
	protected void cleanup() {
		// nothing to do
	}
	
	
	protected boolean shouldReturnUniversalID() {
		return true;
	}
}
