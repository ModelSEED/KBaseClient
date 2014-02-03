#! /usr/bin/python

import argparse
import sys
import os
import json
from biokbase.probabilistic_annotation.Impl import ProbabilisticAnnotation

if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog='pa-runjob')
    parser.add_argument('jobDirectory', help='path to job directory for the job', action='store', default=None)
    args = parser.parse_args()
    
    # Run the job.
    jobDataPath = os.path.join(args.jobDirectory, "jobdata.json")
    job = json.load(open(jobDataPath, 'r'))
    try:
        job['config']['load_data_option'] = 'runjob'
        impl_ProbabilisticAnnotation = ProbabilisticAnnotation(job['config'])
        impl_ProbabilisticAnnotation.runAnnotate(job)
    except Exception as e:
        # Mark the job as failed.
        tb = traceback.format_exc()
        sys.stderr.write(tb)
        ujsClient = UserAndJobState(job['config']['userandjobstate_url'], token=job['context']['token'])
        ujsClient.complete_job(job['id'], job['context']['token'], 'failed', tb, { })
    
    exit(0)
