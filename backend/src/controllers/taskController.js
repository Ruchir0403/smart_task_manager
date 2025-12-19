const supabase = require('../config/supabase');
const { analyzeTask } = require('../services/classifier');

const logHistory = async (taskId, action, oldVal, newVal) => {
  try {
    await supabase.from('task_history').insert({
      task_id: taskId,
      action,
      old_value: oldVal,
      new_value: newVal,
      changed_by: 'system' 
    });
  } catch (error) {
    console.error("Failed to log history:", error);
  }
};

exports.createTask = async (req, res) => {
  try {
    const { title, description, assigned_to, due_date } = req.body;
    
    const analysis = analyzeTask(title, description);
    
    const { data, error } = await supabase
      .from('tasks')
      .insert([{
        title,
        description,
        assigned_to,
        due_date,
        ...analysis,
        status: 'pending'
      }])
      .select()
      .single();

    if (error) throw error;
    await logHistory(data.id, 'created', null, data);
    res.status(201).json({ success: true, data });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
};

exports.getTasks = async (req, res) => {
  try {
    const { category, priority, status, search } = req.query;
    let query = supabase.from('tasks').select('*');

    if (search) {
      query = query.or(`title.ilike.%${search}%,description.ilike.%${search}%`);
    }

    if (category) query = query.eq('category', category);
    if (priority) query = query.eq('priority', priority);
    if (status) query = query.eq('status', status);

    const { data, error } = await query.order('created_at', { ascending: false });
    if (error) throw error;

    res.json({ success: true, count: data.length, data });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
};

exports.updateTask = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    
    const { data: oldData } = await supabase.from('tasks').select('*').eq('id', id).single();
    if (!oldData) return res.status(404).json({ error: "Task not found" });

    const { data, error } = await supabase
      .from('tasks')
      .update({ ...updates, updated_at: new Date() })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    await logHistory(id, 'updated', oldData, data);
    res.json({ success: true, data });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
};

exports.deleteTask = async (req, res) => {
    const { id } = req.params;
    const { error } = await supabase.from('tasks').delete().eq('id', id);
    if (error) return res.status(400).json({ error: error.message });
    res.json({ success: true, message: "Task deleted" });
};