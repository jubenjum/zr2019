import ast
import numpy as np
import pandas
import argparse

def avg(filename, task_type):

    df = pandas.read_csv(filename, sep='\t')
    if task_type == 'across':
        # aggregate on context
        groups = df.groupby(
            ['speaker_1', 'speaker_2', 'phone_1', 'phone_2'], as_index=False)
        df = groups['score'].mean()
    elif task_type == 'within':
        arr = np.array(map(ast.literal_eval, df['by']))
        df['speaker']  = [e for e, f, g in arr]
        df['context'] = [f for e, f, g in arr]
        #del df['by']

        # aggregate on context
        groups = df.groupby(['speaker', 'phone_1', 'phone_2'], as_index=False)
        df = groups['score'].mean()
    else:
        raise ValueError('Unknown task type: {0}'.format(task_type))

    # aggregate on talker
    groups = df.groupby(['phone_1', 'phone_2'], as_index=False)
    df = groups['score'].mean()
    average = df.mean()[0]
    average = (1.0-average)*100
    return average


def main():
    parser = argparse.ArgumentParser(
        description='Compute average score for the ABX discrimination task')

    parser.add_argument(
        'filename',
        help='csv file containing the scores from abx-analyze')

    parser.add_argument(
        'task_type', help='task type : across of within')

    args = parser.parse_args()

    # if dtw distance selected, fore use of normalization parameter :
    if (args.filename is None or args.task_type is None):
        sys.exit("ERROR : missing parameter(s)")

    average=avg(args.filename,args.task_type)
    print("ABX average score =",average)
        

if __name__ == '__main__':
	main()   

