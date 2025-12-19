const analyzeTask = (title, description) => {
  const content = `${title} ${description || ''}`.toLowerCase();
  
  let category = 'general';
  if (content.match(/(meeting|schedule|call|appointment|deadline)/)) category = 'scheduling';
  else if (content.match(/(payment|invoice|bill|budget|cost|expense)/)) category = 'finance';
  else if (content.match(/(bug|fix|error|install|repair|maintain)/)) category = 'technical';
  else if (content.match(/(safety|hazard|inspection|compliance|ppe)/)) category = 'safety';

  let priority = 'low';
  if (content.match(/(urgent|asap|immediately|today|critical|emergency)/)) priority = 'high';
  else if (content.match(/(soon|this week|important)/)) priority = 'medium';

  const entities = {
    dates: content.match(/\d{1,2}\/\d{1,2}|\d{4}-\d{2}-\d{2}|today|tomorrow|monday|friday/g) || [],
    persons: (content.match(/(?:with|by|assign to)\s+([a-zA-Z]+)/i) || [])[1] || null,
  };

  const actionMap = {
    scheduling: ["Block calendar", "Send invite", "Prepare agenda", "Set reminder"],
    finance: ["Check budget", "Get approval", "Generate invoice", "Update records"],
    technical: ["Diagnose issue", "Check resources", "Assign technician", "Document fix"],
    safety: ["Conduct inspection", "File report", "Notify supervisor", "Update checklist"],
    general: ["Review task", "Set deadline"]
  };

  return {
    category,
    priority,
    extracted_entities: entities,
    suggested_actions: actionMap[category] || actionMap['general']
  };
};

module.exports = { analyzeTask };