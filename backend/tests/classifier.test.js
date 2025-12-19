const { analyzeTask } = require('../src/services/classifier');

describe('Task Auto-Classification Logic', () => {
  
  // Test 1: Scheduling + High Priority
  test('should classify as scheduling and high priority', () => {
    const result = analyzeTask('Urgent meeting with team');
    expect(result.category).toBe('scheduling');
    expect(result.priority).toBe('high');
    expect(result.suggested_actions).toContain('Send invite');
  });

  // Test 2: Finance + Medium Priority
  test('should classify as finance and medium priority', () => {
    const result = analyzeTask('Pay invoice soon');
    expect(result.category).toBe('finance');
    expect(result.priority).toBe('medium');
    expect(result.suggested_actions).toContain('Generate invoice');
  });

  // Test 3: Technical + Low Priority
  test('should classify as technical with default low priority', () => {
    const result = analyzeTask('Fix the minor bug in login');
    expect(result.category).toBe('technical');
    expect(result.priority).toBe('low');
  });
});