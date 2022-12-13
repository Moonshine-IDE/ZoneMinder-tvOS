package AllowedTVsAgents;

import java.util.ArrayList;
import java.util.Collection;

import com.moonshine.domino.crud.UpdateAgentBase;
import com.moonshine.domino.field.FieldDefinition;
import com.moonshine.domino.field.FieldType;
import com.moonshine.domino.security.*;
import com.moonshine.domino.util.DominoUtils;
import com.moonshine.domino.util.ParameterException;

import lotus.domino.*;

public class AllowedTVsUpdate extends UpdateAgentBase {
	 

	protected Collection<FieldDefinition> getFieldList() {
		Collection<FieldDefinition> fields = new ArrayList<FieldDefinition>();
		fields.add(new FieldDefinition("ID", FieldType.TEXT, false));


		fields.add(new FieldDefinition("tvName", FieldType.TEXT, false));


		fields.add(new FieldDefinition("availableCameras", FieldType.TEXT, true));



		return fields;
	}
	

	protected Object getDocumentIdentifier() throws ParameterException {
		Collection<FieldDefinition> keys = new ArrayList<FieldDefinition>();
		keys.add(new FieldDefinition(getUniversalIDName(), FieldType.TEXT, false));
		
		/* You can use custom keys like this
		keys.add(new FieldDefinition("tvName", FieldType.TEXT, false));


		*/
		
		return getKeyRequired(keys);
	}
	

	protected View getLookupView() throws NotesException {
		return null;
		
		/* For custom keys
		try {
			return DominoUtils.getView(agentDatabase, "Allowed TVs");
		}
		catch (Exception ex) {
			getLog().err("Could not open lookup view: ", ex);
			return null;
		}
		*/
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
}
